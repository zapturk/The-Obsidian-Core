class_name Room
extends Node2D

@onready var doors := {
	Vector2i.UP: $DoorTop,
	Vector2i.RIGHT: $DoorRight,
	Vector2i.DOWN: $DoorDown,
	Vector2i.LEFT: $DoorLeft,
}

func setup_doors(neighbors: Array) -> void:
	for direction in doors:
		var door_node = doors[direction]
		if neighbors.has(direction):
			door_node.SetDoorType(Types.DoorType.None)
		else:
			door_node.SetDoorType(Types.DoorType.Wall)
