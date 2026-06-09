extends Node2D

# Constants
const TILE_SIZE = 16

# State variables
var is_moving: bool = false
var current_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	update_interact_direction()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if has_node("Interact"):
			$Interact.CheckForInteraction()

func _physics_process(_delta: float) -> void:
	if is_moving:
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

		current_direction = direction
		update_interact_direction()
		try_move(direction)

func update_interact_direction() -> void:
	if has_node("Interact"):
		$Interact.target_position = current_direction * TILE_SIZE

func try_move(direction: Vector2) -> void:
	var next_pos = position + (direction * TILE_SIZE)
	move_to(next_pos)

func move_to(new_pos: Vector2) -> void:
	is_moving = true
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): is_moving = false)
