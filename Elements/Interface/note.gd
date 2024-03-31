extends Area3D
@export var KeyToDsiplay:String
@export var InterfaceToDisplay:PackedScene
var interfaceinstance
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		interfaceinstance = InterfaceToDisplay.instantiate()
		add_child(interfaceinstance)
		interfaceinstance.get_child(0).text = KeyToDsiplay
		


func _on_body_exited(body):
	if body.name == "Player":
		if interfaceinstance != null:
			interfaceinstance.queue_free()
			interfaceinstance = null
		
