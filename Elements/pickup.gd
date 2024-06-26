extends Node3D

@export var item:Item

@onready var area_3d = %Area3D
@onready var animation_player = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var instance = item.scene.instantiate()
	area_3d.add_child(instance)
	animation_player.play("pickup_animation")


func _on_area_3d_body_entered(body):
	if body.has_method("on_item_picked_up"):
		body.on_item_picked_up(item)
		queue_free()


func _on_area_3d_input_event(camera, event, _position, _normal, _shape_idx):
	if event.button_mask == 1:
		var distance_to:float = camera.global_position.distance_to(_position)
		if distance_to < 2:
			print("Grabbed")
