extends CharacterBody2D

class_name Monster

enum MonsterStates {
	Idle,
	Moving
}

var state := MonsterStates.Idle
var animationSpeed := 3
var current_dir := Vector2.DOWN

@onready var sprite := $AnimatedSprite2D # Assuming there is an AnimatedSprite2D
@onready var solid_detector := $SolidDetector # Assuming there is a SolidDetector
@onready var onScreen := $VisibleOnScreenNotifier2D

var objVisible := false

func _ready() -> void:
	EventBus.PlayerActionTaken.connect(_on_player_action_taken)
	onScreen.screen_entered.connect(func() -> void: objVisible = true)
	onScreen.screen_exited.connect(func() -> void: objVisible = false)

func _on_player_action_taken(player_pos: Vector2) -> void:
	# We use the passed position instead of searching for the player node
	plan_and_move_towards_player_at(player_pos)

func plan_and_move_towards_player_at(target_pos: Vector2) -> void:
	if not objVisible:
		return
	var monster_pos = position
	
	var diff = target_pos - monster_pos
	var direction = Vector2.ZERO
	
	if abs(diff.x) > abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	else:
		direction = Vector2(0, sign(diff.y))
	
	if direction != Vector2.ZERO:
		try_move(direction)

func try_move(dir: Vector2) -> void:
	if solid_detector:
		solid_detector.SetTargetPosition(dir * Global.TILE_SIZE)
		if solid_detector.IsSolidAhead():
			return
		
	move_to(dir)

func move_to(dir: Vector2) -> void:
	state = MonsterStates.Moving
	current_dir = dir
	
	#if sprite:
		#sprite.play("Walk" + get_ani_dir(dir))
		
	var tween = create_tween()
	tween.tween_property(self, "position", position + (dir * Global.TILE_SIZE), 1.0 / animationSpeed)
	await tween.finished
	
	state = MonsterStates.Idle
	#if sprite:
		#sprite.play("Idle" + get_ani_dir(current_dir))

func get_ani_dir(dir: Vector2) -> String:
	match dir:
		Vector2.RIGHT: return "Right"
		Vector2.UP: return "Up"
		Vector2.DOWN: return "Down"
		Vector2.LEFT: return "Left"
		_: return "Down"
