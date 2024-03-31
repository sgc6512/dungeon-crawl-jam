class_name Enemy
extends Area3D

@onready var astar:AStar3D = AStar3D.new()
@export var grid_map:GridMap
@export var health:int = 10

@onready var gridmap_cells:Array[Vector3i]
@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var animation_player = %AnimationPlayer
@onready var attack_ray = %AttackRay
@onready var timer = %Timer


func take_damage(_damage:int):
	health -= _damage
	if health <= 0:
		queue_free()


func _ready():
	add_to_group("enemy")
	
	gridmap_cells = grid_map.get_used_cells()
	
	# Add points to AStar Map
	var id_counter:int = 1
	for pos in gridmap_cells:
		# Based off the index on MeshLibrary
		match grid_map.get_cell_item(pos):
			10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 39: # 0 : Plane
				astar.add_point(encode_id(1, id_counter), pos)
				id_counter += 1
			24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 41, 42: # 1 : Incline or Stairs
				astar.add_point(encode_id(2, id_counter), pos)
				id_counter += 1
			_: # 2 : Cube
				pass
	
	# Connect points
	for point_origin in astar.get_point_ids():
		for point_destination in astar.get_point_ids():
			var pos_origin:Vector3 = astar.get_point_position(point_origin)
			var pos_destination:Vector3 = astar.get_point_position(point_destination)
			
			# Decode ID to determine the type of cell
			var origin_type:int = point_origin / 1000
			var destination_type:int = point_destination / 1000
			
			# Handle connections if points are planes
			if origin_type == 1 and destination_type == 1:
				# Check if points are directly adjacent
				if pos_origin.distance_to(pos_destination) == 1.0:
					astar.connect_points(point_origin, point_destination)
			
			# Handle inclines
			if origin_type == 2:
				# Grab orientation / Note this probably only works for the specific test meshes I've created
				# I don't know if these orientation values would be the same for any mesh
				# Probably worth looking into changing it to use get_cell_item_basis instead
				var orientation = grid_map.get_cell_item_orientation(pos_origin)
				
				# If adjacent inclines add them as a connection
				# Note that orientation doesn't matter here as we shouldn't have inclines of different
				# orientations adjacent to one another
				if destination_type == 2 and pos_origin.distance_to(pos_destination) == 1.0:
					astar.connect_points(point_origin, point_destination)
				
				# Based on the orientation add a plane as a connection
				# This has a bug, check for z or x as well respectively
				match orientation:
					0, 10: # 0  : Right +X | 10 : Left -X
						# Add planes to the right and left
						if pos_origin.x == pos_destination.x + 1 and pos_origin.z == pos_destination.z:
							astar.connect_points(point_origin, point_destination)
						if pos_origin.x == pos_destination.x - 1 and pos_origin.z == pos_destination.z:
							astar.connect_points(point_origin, point_destination)
					16, 22: # 16 : Up -Z | 22 : Down +Z
						if pos_origin.z == pos_destination.z + 1 and pos_origin.x == pos_destination.x:
							astar.connect_points(point_origin, point_destination)
						if pos_origin.z == pos_destination.z - 1 and pos_origin.x == pos_destination.x:
							astar.connect_points(point_origin, point_destination)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# This is so that we know if a cell on the grid map
# Is a flat plane, or an incline
func encode_id(type:int, index:int) -> int:
	return type * 1000 + index # Adjust multiplier if you need more cells


func _on_timer_timeout():
	# Bug fixing note, local_to_map doesn't plot the right position if we are on an incline
	# This fix works but there is probably a better way to do it
	if astar.get_point_ids().size() == 0:
		return
	var target_position:Vector3i = grid_map.local_to_map(player.position)
	var origin_position:Vector3 = grid_map.local_to_map(position)
	
	if !target_position in gridmap_cells:
		target_position.y -= 1
	
	var target_id = astar.get_closest_point(target_position)
	var origin_id = astar.get_closest_point(origin_position)
	
	
	var path = astar.get_id_path(origin_id, target_id).slice(1)
	if path.is_empty():
		return
	
	# Handle rotation towards target
	# Bug fixing note, rotating in a circle breaks this needs to be fixed
	var dir:Vector3 = origin_position.direction_to(astar.get_point_position(path[0]))
	var rotate_by = null
	match dir: 
		Vector3(1, 0, 0): # Front
			rotate_by = 0
		Vector3(-1, 0, 0): # Behind
			rotate_by = 180
		Vector3(0, 0, 1): # Right
			rotate_by = 270
		Vector3(0, 0, -1): # Left
			rotate_by = 90
	
	if rotate_by != null:
		var current_rotation = rotation_degrees.y
		if absi(current_rotation - rotate_by) > 180:
			rotate_by -= 360
		if rotate_by != rotation_degrees.y:
			#print(current_rotation, " ", rotate_by)
			var tween = create_tween()
			tween.tween_property(self, "rotation_degrees:y", rotate_by, 0.3).set_trans(
				Tween.TRANS_SINE)
			return
	
	if path.size() == 1:
		# Next to player, either flank or try to attack
		var rand = randi_range(0, 1)
		if rand:
			flank()
		else:
			try_attack()
		return
	
	var next_step = grid_map.map_to_local(astar.get_point_position(path[0]))
	var type:int = path[0] / 1000
	if type == 2:
		next_step.y += 1.5
	else:
		next_step.y += 1
	
	var tween = create_tween()
	tween.tween_property(self, "position", next_step, 0.3).set_trans(
		Tween.TRANS_SINE)


func try_attack():
	timer.stop()
	animation_player.play("attack")
	await get_tree().create_timer(0.5).timeout
	if attack_ray.is_colliding():
		var coll:Object = attack_ray.get_collider()
		if coll.has_method("take_damage"):
			coll.call("take_damage", 5)
	timer.start()


func flank():
	timer.stop()
	var target_position:Vector3i = grid_map.local_to_map(player.position)
	var origin_position:Vector3i = grid_map.local_to_map(position)
	var origin_id = astar.get_closest_point(origin_position)

	var possible_flanks:Array = []
	var offset = target_position - origin_position
	# Based on offset check up down or left right
	if offset.z == 1 or offset.z == -1:
		for i in [-1,1]:
			var step1 = origin_position + Vector3i(i, 0, 0)
			var step1_id = astar.get_closest_point(step1)
			var step2 = target_position + Vector3i(i, 0, 0)
			var step2_id = astar.get_closest_point(step2)
			if astar.are_points_connected(origin_id, step1_id) and astar.are_points_connected(step1_id, step2_id):
				possible_flanks.append(step1)
				possible_flanks.append(step2)
	else:
		for i in [-1,1]:
			var step1 = origin_position + Vector3i(0, 0, i)
			var step1_id = astar.get_closest_point(step1)
			var step2 = target_position + Vector3i(0, 0, i)
			var step2_id = astar.get_closest_point(step2)
			if astar.are_points_connected(origin_id, step1_id) and astar.are_points_connected(step1_id, step2_id):
				possible_flanks.append(step1)
				possible_flanks.append(step2)
	
	if possible_flanks.size() > 2:
		var rand = randi_range(0, 1)
		if rand:
			possible_flanks = possible_flanks.slice(0, -2)
		else:
			possible_flanks = possible_flanks.slice(2)

	# Rapidly move around the player
	var tween = create_tween()
	for pos in possible_flanks:
		var move = grid_map.map_to_local(pos)
		move.y += 1
		tween.tween_property(self, "position", move, 0.15).set_trans(
			Tween.TRANS_SINE)
	timer.start()
