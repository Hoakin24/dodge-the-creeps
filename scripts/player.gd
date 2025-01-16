extends Area2D

signal hit

@export var speed = 400
@export var max_teleport_distance = 200  
@export var ammo = 3

var screen_size
var player_size
var game_start = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_size = $CollisionShape2D.shape.get_rect().size
	$ActionAnimations2D.animation = 'teleport'
	$ActionAnimations2D.stop()
	$ActionAnimations2D.hide()
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# initiate variables
	if game_start:
		var velocity = Vector2.ZERO
		var target_pos = get_viewport().get_mouse_position()
		
		# handle teleport
		if $TeleportTimer.is_stopped() and Input.is_action_just_pressed("teleport"):
			var distance = position.distance_to(target_pos)
			
			var teleport_direction = (target_pos - position).normalized()
			
			var angle_to_mouse = teleport_direction.angle()
			var offset_distance = 100  
			var offset_position = position - teleport_direction * offset_distance
			
			$TeleportSoundFX.play()
			
			$ActionAnimations2D.rotation = angle_to_mouse
			$ActionAnimations2D.global_position = offset_position 
			
			position += teleport_direction * max_teleport_distance
			
			$ActionAnimations2D.show()
			$ActionAnimations2D.play()
			
			$TeleportTimer.start()
		
		# handle shooting
		if ammo != 0 and $ReloadTimer.is_stopped() and Input.is_action_just_pressed("shoot"):
			var space_state = get_world_2d().direct_space_state
			var shooting_direction = (target_pos - position).normalized()
			
			var max_distance = screen_size.length()
			var extended_point = position + shooting_direction * max_distance 
			
			var query = PhysicsRayQueryParameters2D.create(position, target_pos)
			var result = space_state.intersect_ray(query)
			ammo -= 1
			
			$ShootingLine2D.clear_points()  
			$ShootingLine2D.add_point(to_local(global_position)) 
			
			if result:
				$ShootingLine2D.add_point(to_local(result.position))
				if result.collider and result.collider is Node2D:
					result.collider.queue_free() 
			else:
				$ShootingLine2D.add_point(to_local(extended_point))
				
			$ShootSoundFX.play()
			if ammo == 0:
				$ReloadTimer.start()
			
			await get_tree().create_timer(0.01).timeout
			$ShootingLine2D.clear_points()
			
		# handle movement
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
			
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$PlayerAnimation2D.play()
		else:
			$PlayerAnimation2D.stop()
			
		position += velocity * delta
		position = position.clamp(Vector2.ZERO+player_size/2, screen_size-player_size/2)
		
		if velocity.x != 0:
			$PlayerAnimation2D.animation = "walk"
		elif velocity.y != 0:
			$PlayerAnimation2D.animation = "up"

		$PlayerAnimation2D.flip_h = velocity.x < 0
		$PlayerAnimation2D.flip_v = velocity.y > 0


func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	game_start = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	
func start(pos):
	position = pos
	ammo = 3
	show()
	game_start = true
	$CollisionShape2D.disabled = false


func _on_teleport_timer_timeout() -> void:
	$TeleportTimer.stop()


func _on_action_animations_2d_animation_looped() -> void:
	$ActionAnimations2D.stop()
	$ActionAnimations2D.hide()


func _on_reload_timer_timeout() -> void:
	$ReloadTimer.stop()
	ammo = 3
