class_name Player
extends CharacterBody3D

@onready var animation_player = %AnimationPlayer
@onready var moving:bool = false
@onready var blocking:bool = false
@onready var right_ray = %RightRay
@onready var left_ray = %LeftRay
@onready var up_ray = %UpRay
@onready var down_ray = %DownRay
@onready var slash_2d = %Slash2D
@onready var block_timer = %BlockTimer

# Exports
@export var animation_time:float = 0.3
@export var damage:int = 5
@export var health:int = 10

# Controlled by tween
@onready var desired_position:Vector3 = position

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var inventory:Inventory = Inventory.new()


func on_item_picked_up(item:Item):
	inventory.add_item(item)


func _ready():
	if !is_in_group("player"):
		add_to_group("player")


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and !moving and check_wall_collision(input_dir):
		var tween = create_tween()
		moving = true
		tween.tween_property(self, "desired_position", direction * 2, animation_time).as_relative().set_trans(
			Tween.TRANS_SINE)
		animation_player.play("headbob")
		tween.connect("finished", on_tween_finished)
	
	# Handle gravity
	if !is_on_floor():
		position.y -= gravity * delta
	
	# Snap to tween in X and Z axis
	position.x = desired_position.x
	position.z = desired_position.z

	# Needed to work with is_on_floor method
	move_and_slide()


func _input(event):
	# Handle rotation
	if (event.is_action_pressed("rotate_left") or event.is_action_pressed("rotate_right")) and !moving:
		var tween = create_tween()
		moving = true
		
		var rot_deg = 90
		if event.is_action("rotate_right"):
			rot_deg = -90
		
		tween.tween_property(self, "rotation_degrees:y", rot_deg, animation_time).as_relative().set_trans(
			Tween.TRANS_SINE)
		tween.connect("finished", on_tween_finished)
	
	# Handle attack
	if event.is_action_pressed("attack") and !moving and !blocking:
		# Delay between attacks
		moving = true
		slash_2d.play()
		await get_tree().create_timer(0.3).timeout
		moving = false
		
		# Check for hit
		var col_obj:Object = check_collider_in_front()
		if col_obj and col_obj.has_method("take_damage"):
			col_obj.call("take_damage", damage)
	
	# Handle block
	if event.is_action_pressed("block"):
		animation_player.play("block")
		blocking = true
		block_timer.start()
		#animation_player.play_backwards("block")


func on_tween_finished():
	moving = false


func check_wall_collision(_input_dir:Vector2) -> bool:
	# Should likely specify that the collision is a wall
	match _input_dir:
		Vector2(1, 0): # Right
			if right_ray.is_colliding():
				return false
		Vector2(-1, 0): # Left
			if left_ray.is_colliding():
				return false
		Vector2(0, 1): # Down
			if down_ray.is_colliding():
				return false
		Vector2(0, -1): # Up
			if up_ray.is_colliding():
				return false
	return true


func check_collider_in_front() -> Object:
	return up_ray.get_collider()


func take_damage(_damage:int):
	if !blocking:
		health -= _damage
	else:
		blocking = false
		animation_player.play_backwards("block")
	print(health)


func _on_block_timer_timeout():
	if blocking:
		blocking = false
		animation_player.play_backwards("block")
