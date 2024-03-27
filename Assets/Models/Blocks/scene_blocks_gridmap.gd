@tool

extends Node3D

@export_category("Debug")
@export var Generate: bool:
	set(value):
		button_pressed()

func button_pressed():
	print("pressed")
	for child in get_children(true):
		if child.is_class("MeshInstance3D"):
			var body = StaticBody3D.new()
			body.owner = self
			child.add_child(body)
		print(child)
