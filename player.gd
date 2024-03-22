class_name Player
extends CharacterBody3D
@onready var player = %Player
@onready var moving:bool = false
@onready var target_position:Vector2 = Vector2(100, 100)
@onready var player_size:Vector3 = Vector3(1,1.5,1)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(_delta):
	# Accessing space required for Raycasts
	var space_state = get_world_3d().direct_space_state
	
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
	
	var floor_raycast = check_floor(space_state)
	if floor_raycast.has("collider"):
		position.y = floor_raycast.position.y + player_size.y
	else:
		position.y -= gravity * _delta
	
	# Potentially not needed as we are not using the velocity
	# move_and_slide()


func on_tween_finished():
	moving = false


func check_floor(space):
	# Create starting and target point of the ray, offset the target by small fraction
	var origin_pos = global_position
	var target_pos = global_position - Vector3(0, player_size.y + 0.1, 0)
	var floor_query = PhysicsRayQueryParameters3D.create(origin_pos, target_pos)
	var floor_result = space.intersect_ray(floor_query)
	# Test for debugging
	#print(floor_result.collider if floor_result.has("collider") else "Nothing")
	return floor_result
