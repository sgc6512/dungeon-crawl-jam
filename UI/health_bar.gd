extends Control

@export var total_health:int = 10
@export var current_health:int = 10
@onready var margin_container = %MarginContainer
@onready var color_rect = %ColorRect
@onready var length:float = color_rect.size.x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_health(amount:int):
	current_health = amount
	var tween = create_tween()
	var step = length / total_health
	tween.tween_property(margin_container, "size:x", step * current_health, 0.25).set_trans(Tween.TRANS_SINE)
