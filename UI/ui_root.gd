extends CanvasLayer

@onready var player = %Player
@onready var inventory_dialog = %InventoryDialog
@onready var health_bar = %HealthBar
@onready var title_screen = %TitleScreen
@onready var game_over = %GameOver


func _unhandled_input(event):
	if event.is_action_released("inventory"):
		if inventory_dialog.visible:
			inventory_dialog.hide()
		else:
			inventory_dialog.open(player.inventory)


func _process(_delta):
	if player.health != health_bar.current_health:
		health_bar.change_health(player.health)
	if title_screen.start_game and !health_bar.visible:
		health_bar.show()
	
	if player.health <= 0:
		game_over.show()
		get_tree().paused = true
