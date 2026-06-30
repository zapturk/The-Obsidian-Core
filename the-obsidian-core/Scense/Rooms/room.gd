class_name Room
extends Node2D

func setup_doors(neighbors: Array) -> void:
	if neighbors.has(Vector2i.UP):
		$DoorTop.SetDoorType(Types.DoorType.None)
	else:
		$DoorTop.SetDoorType(Types.DoorType.Wall)
	
	if neighbors.has(Vector2i.RIGHT):
		$DoorRight.SetDoorType(Types.DoorType.None)
	else:
		$DoorRight.SetDoorType(Types.DoorType.Wall)
		
	if neighbors.has(Vector2i.DOWN):
		$DoorDown.SetDoorType(Types.DoorType.None)
	else:
		$DoorDown.SetDoorType(Types.DoorType.Wall)
		
	if neighbors.has(Vector2i.LEFT):
		$DoorLeft.SetDoorType(Types.DoorType.None)
	else:
		$DoorLeft.SetDoorType(Types.DoorType.Wall)
