extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_open_doors_body_entered(body):
	if body.name == "Player":
		$LevelCity/DoorsRoot/RootSceneDoors.queue_free()
		$LevelCity/DoorsRoot/RootSceneDoors2.queue_free()
		$LevelCity/DoorsRoot/RootSceneDoors3.queue_free()
		self.visible = false
