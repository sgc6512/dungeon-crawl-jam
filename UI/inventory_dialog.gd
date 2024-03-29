class_name InventoryDialog
extends PanelContainer


@onready var grid_container:GridContainer = %GridContainer

@export var slot_scene:PackedScene


func open(inventory:Inventory):
	show()
	
	for child in grid_container.get_children():
		child.queue_free()
	
	for item in inventory.get_items():
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.display(item)


func _on_close_pressed():
	hide()
