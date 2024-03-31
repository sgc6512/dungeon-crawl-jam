class_name InventoryDialog
extends PanelContainer


@onready var item_list = %ItemList
@onready var info = %Info

@export var slot_scene:PackedScene


func open(inventory:Inventory):
	show()
	
	item_list.clear()
	
	for item in inventory.get_items():
		var index = item_list.add_item(item.name)
		item_list.set_item_metadata(index, item)


func _on_close_pressed():
	hide()


func _on_item_list_item_selected(index):
	var item = item_list.get_item_metadata(index)
	info.text = item.details
