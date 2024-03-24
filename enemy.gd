extends Area3D

@onready var astar:AStar3D = AStar3D.new()
@export var grid_map:GridMap
@onready var gridmap_cells:Array[Vector3i]
@onready var player:Player = get_tree().get_first_node_in_group("player")

func _ready():
	gridmap_cells = grid_map.get_used_cells()
	
	# Add points to AStar Map
	var id_counter:int = 1
	for pos in gridmap_cells:
		# Based off the index on MeshLibrary
		match grid_map.get_cell_item(pos):
			0: # 0 : Plane
				astar.add_point(encode_id(1, id_counter), pos)
				id_counter += 1
			1: # 1 : Incline
				astar.add_point(encode_id(2, id_counter), pos)
				id_counter += 1
			2: # 2 : Cube
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
				match orientation:
					0, 10: # 0  : Right +X | 10 : Left -X
						# Add planes to the right and left
						if pos_origin.x == pos_destination.x + 1:
							astar.connect_points(point_origin, point_destination)
						if pos_origin.x == pos_destination.x - 1:
							astar.connect_points(point_origin, point_destination)
					16, 22: # 16 : Up -Z | 22 : Down +Z
						if pos_origin.z == pos_destination.z + 1:
							astar.connect_points(point_origin, point_destination)
						if pos_origin.z == pos_destination.z - 1:
							astar.connect_points(point_origin, point_destination)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This is so that we know if a cell on the grid map
# Is a flat plane, or an incline
func encode_id(type:int, index:int) -> int:
	return type * 1000 + index # Adjust multiplier if you need more cells


func _on_timer_timeout():
	# Bug fixing note, local_to_map doesn't plot the right position if we are on an incline
	# This fix works but there is probably a better way to do it
	var target_position:Vector3i = grid_map.local_to_map(player.position)
	var origin_position:Vector3i = grid_map.local_to_map(position)
	
	if !target_position in gridmap_cells:
		target_position.y -= 1
	
	var origin_id = astar.get_closest_point(origin_position)
	var target_id = astar.get_closest_point(target_position)
	
	var path = astar.get_point_path(origin_id, target_id).slice(1)
	
	if path.is_empty():
		return
	
	var next_step = grid_map.map_to_local(path[0])
	next_step.y += 1
	var tween = create_tween()
	tween.tween_property(self, "position", next_step, 0.3).set_trans(
		Tween.TRANS_SINE)
