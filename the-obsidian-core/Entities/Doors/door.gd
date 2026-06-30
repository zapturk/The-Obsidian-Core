extends Node2D
class_name Door

@onready var solid := $Solid
@onready var posToString := {
	Types.DoorPos.Top: "Top",
	Types.DoorPos.Right: "Right",
	Types.DoorPos.Down: "Down",
	Types.DoorPos.Left: "Left",
}
@export var pos: Types.DoorPos



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func Open() -> void:
	# play animaiton
	
	solid.DisableSolid()
	
	

func Close() -> void:
	# play animaiton
	
	solid.EnableSolid()

func SetDoorType(doorType: Types.DoorType) -> void:
	match doorType:
		Types.DoorType.None:
			$AnimatedSprite2D.play("None")
			solid.DisableSolid()
		Types.DoorType.Wall:
			$AnimatedSprite2D.play(posToString[pos] + "Wall")
			solid.EnableSolid()
		
