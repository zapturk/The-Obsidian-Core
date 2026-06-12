extends Node2D
class_name Sign

@export var SignMessage: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_interactable_trigger_interaction() -> void:
	print(SignMessage)
