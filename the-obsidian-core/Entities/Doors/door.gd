extends Node2D


@onready var solid = $Solid


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Open()
	if Input.is_action_just_pressed("ui_cancel"):
		Close()

func Open() -> void:
	# play animaiton
	
	solid.DisableSolid()
	
	

func Close() -> void:
	# play animaiton
	
	solid.EnableSolid()
