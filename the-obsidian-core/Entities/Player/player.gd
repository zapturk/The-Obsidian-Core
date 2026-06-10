extends Node2D

# State variables
var IsMoving := false
var CurrentDir := Vector2.DOWN

@onready var interactRay := $Interact
@onready var solidDectector := $SolidDetector

func _ready() -> void:
	UpdateInteractDir()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		interactRay.CheckForInteraction()

func _physics_process(_delta: float) -> void:
	if IsMoving:
		return

	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		direction += Vector2.RIGHT

	if direction != Vector2.ZERO:
		# Prioritize cardinal directions (no diagonals)
		if direction.x != 0 and direction.y != 0:
			if abs(direction.x) > abs(direction.y):
				direction = Vector2(sign(direction.x), 0)
			else:
				direction = Vector2(0, sign(direction.y))
		else:
			direction = direction.normalized()

		CurrentDir = direction
		UpdateInteractDir()
		TryMove(direction)

func UpdateInteractDir() -> void:
	interactRay.target_position = CurrentDir * Global.TILE_SIZE
	
	solidDectector.target_position = CurrentDir * Global.TILE_SIZE

func TryMove(direction: Vector2) -> void:
	solidDectector.target_position = direction * Global.TILE_SIZE
	if solidDectector.is_solid_ahead():
		return

	var nextPos = position + (direction * Global.TILE_SIZE)
	MoveTo(nextPos)

func MoveTo(new_pos: Vector2) -> void:
	IsMoving = true
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): IsMoving = false)
