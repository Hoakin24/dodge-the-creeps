extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var selected_mob_type = mob_types[randi() % mob_types.size()]
	$AnimatedSprite2D.play(selected_mob_type)
	
	if selected_mob_type == 'fly':
		$CollisionShape2DFly.disabled = false
		$CollisionShape2DWalkSwim.disabled = true
	else:
		$CollisionShape2DFly.disabled = true
		$CollisionShape2DWalkSwim.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
