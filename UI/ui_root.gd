extends CanvasLayer

@onready var player = %Player
@onready var inventory_dialog = %InventoryDialog


func _unhandled_input(event):
	if event.is_action_released("inventory"):
		if inventory_dialog.visible:
			inventory_dialog.hide()
		else:
			inventory_dialog.open(player.inventory)
