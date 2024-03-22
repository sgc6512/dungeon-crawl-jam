class_name Player
extends CharacterBody3D
@onready var player = %Player
@onready var moving:bool = false
@onready var target_position:Vector2 = Vector2(100, 100)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# Decided to stick with tweening. We can handle going up slopes or falling down as edge cases
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !moving:
		var tween = create_tween()
		moving = true
		tween.tween_property(player, "position", direction, 0.5).as_relative().set_trans(
			Tween.TRANS_SINE)
		tween.connect("finished", on_tween_finished)
	
	# Handle rotation
	if Input.is_action_just_released("rotate_left") and !moving:
		var tween = create_tween()
		moving = true
		tween.tween_property(player, "rotation_degrees:y", 90, 0.5).as_relative().set_trans(
			Tween.TRANS_SINE)
		tween.connect("finished", on_tween_finished)
	if Input.is_action_just_released("rotate_right") and !moving:
		var tween = create_tween()
		moving = true
		tween.tween_property(player, "rotation_degrees:y", -90, 0.5).as_relative().set_trans(
			Tween.TRANS_SINE)
		tween.connect("finished", on_tween_finished)
	
	# Potentially not needed as we are not using the velocity
	# move_and_slide()


func on_tween_finished():
	moving = false
