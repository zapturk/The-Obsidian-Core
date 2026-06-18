class_name Player extends Node2D

enum PlayerStates {
	None,
	Turn,
	Moving,
	Idle,
	Talk
}

# State variables
var IsMoving := false
var CurrentDir := Vector2.DOWN
var animationSpeed := 3
var state := PlayerStates.Idle

@onready var interactRay := $Interact
@onready var solidDetector := $SolidDetector
@onready var sprite := $AnimatedSprite2D


func _ready() -> void:
	UpdateInteractDir()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		interactRay.CheckForInteraction()

func _physics_process(_delta: float) -> void:
	if state == PlayerStates.Moving || state == PlayerStates.None:
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
	interactRay.SetTargetPosition(CurrentDir * Global.TILE_SIZE)
	solidDetector.SetTargetPosition(CurrentDir * Global.TILE_SIZE)

func TryMove(direction: Vector2) -> void:
	if solidDetector.IsSolidAhead():
		sprite.play("Idle" + getAniDir(CurrentDir))
		return

	MoveTo(direction)
	

func MoveTo(dir: Vector2) -> void:
	state = PlayerStates.Moving
	sprite.play("Walk" + getAniDir(dir))
	var tween = create_tween()
	tween.tween_property(self, "position", position + (dir * Global.TILE_SIZE), 1.0 / animationSpeed)
	await tween.finished
	state = PlayerStates.Idle
	sprite.play("Idle" + getAniDir(CurrentDir))

func getAniDir(dir: Vector2) -> String:
	match dir:
		Vector2.RIGHT:
			return "Right"
		Vector2.UP:
			return "Up"
		Vector2.DOWN:
			return "Down"
		Vector2.LEFT:
			return "Left"
		_:
			return "Down"
	
