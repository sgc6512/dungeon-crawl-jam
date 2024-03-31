extends PanelContainer

@onready var label = %Label
@onready var title = %Title
@onready var v_box_container = %VBoxContainer
@onready var button = %Button
@onready var skip = %Skip

var start_game = false
var init = true
var scrolling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	label.position.y = 648


func _process(_delta):
	if init:
		label.position.y = 648
		skip.position.y = 648
		init = false

func _unhandled_input(event):
	if event.is_action_pressed("rotate_right") and scrolling:
		print("Skipping animation")
		on_tween_finished()

func _on_button_pressed():
	scrolling = true
	skip.position.y = 625
	var tween = create_tween()
	var tween2 = create_tween()
	button.disabled = true
	tween.tween_property(label, "position:y", 0 - label.size.y, 30)
	tween2.tween_property(v_box_container, "modulate:a", 0, 1)
	tween.connect("finished", on_tween_finished)


func on_tween_finished():
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 1).finished
	hide()
	start_game = true
	get_tree().paused = false
