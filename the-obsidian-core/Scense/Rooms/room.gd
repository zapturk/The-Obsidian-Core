class_name Room
extends Node2D

#@onready var door_up = $DoorsUp
#@onready var door_down = $DoorsDown
#@onready var door_left = $Doors/Left
#@onready var door_right = $Doors/Right

func setup_doors(neighbors: Array) -> void:
	print(neighbors)
	#door_up.visible = neighbors.contains(Vector2i.UP)
	#door_down.visible = neighbors.contains(Vector2i.DOWN)
	#door_left.visible = neighbors.contains(Vector2i.LEFT)
	#door_right.visible = neighbors.contains(Vector2i.RIGHT)
