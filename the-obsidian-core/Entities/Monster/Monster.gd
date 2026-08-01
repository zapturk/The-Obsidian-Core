extends CharacterBody2D

class_name Monster

enum MonsterStates {
	Idle,
	Moving,
	Attack
}

var state := MonsterStates.Idle
var animationSpeed := 3
var current_dir := Vector2.DOWN

@onready var sprite := $AnimatedSprite2D # Assuming there is an AnimatedSprite2D
@onready var solid_detector := $SolidDetector # Assuming there is a SolidDetector
@onready var onScreen := $VisibleOnScreenNotifier2D

var objVisible := false
var my_name: String = ""
func _ready() -> void:
	EventBus.PlayerActionTaken.connect(_on_player_action_taken)
	onScreen.screen_entered.connect(func() -> void: objVisible = true)
	onScreen.screen_exited.connect(func() -> void: objVisible = false)

func _on_player_action_taken(player_pos: Vector2) -> void:
	# We use the passed position instead of searching for the player node
	plan_and_move_towards_player_at(player_pos)

func get_room_global_position() -> Vector2:
	var room = get_parent()
	if room == null:
		return Vector2.ZERO
	return room.global_position

func get_room_global_boundaries() -> Rect2:
	var room_pos = get_room_global_position()
	return Rect2(room_pos, Vector2(256, 144))

func is_player_in_same_room(player_global_pos: Vector2) -> bool:
	var room_bounds = get_room_global_boundaries()
	return room_bounds.has_point(player_global_pos)

func plan_and_move_towards_player_at(target_pos: Vector2) -> void:
	if not objVisible:
		return
	
	# Check if the player is in the same room — ignore if in a different room
	if not is_player_in_same_room(target_pos):
		print("[", my_name, "] Player is in a different room, ignoring target: ", target_pos)
		return
	var monster_pos = global_position

	var diff = target_pos - monster_pos

	# Check if the player is adjacent to the monster (Cardinal directions only) — ATTACK immediately
	if diff != Vector2.ZERO and abs(diff.x) + abs(diff.y) == Global.TILE_SIZE:
		print("[", my_name, "] ADJACENT to player at ", target_pos, " — ATTACKING from ", monster_pos)
		attack()
		return

	var direction = Vector2.ZERO
	if abs(diff.x) > abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	else:
		direction = Vector2(0, sign(diff.y))

	if direction != Vector2.ZERO:
		# Check if the next step is the player's position — ATTACK instead
		if monster_pos + (direction * Global.TILE_SIZE) == target_pos:
			print("[", my_name, "] MOVING toward player at ", target_pos, " but will ATTACK instead — monster was at ", monster_pos)
			attack()
			return
		# Otherwise move toward the player
		print("[", my_name, "] Moving from ", monster_pos, " to ", monster_pos + (direction * Global.TILE_SIZE), " (player is at ", target_pos, ")")
		try_move(direction)

	# After moving, check if the player is now adjacent — if so, attack
	if objVisible:
		diff = target_pos - global_position
		if diff != Vector2.ZERO and abs(diff.x) + abs(diff.y) == Global.TILE_SIZE:
			print("[", my_name, "] Post-move check: monster at ", global_position, " player at ", target_pos, " — ADJACENT, ATTACKING")
			attack()
			return

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

func attack() -> void:
	state = MonsterStates.Attack
	print("attack")
	state = MonsterStates.Idle

func get_ani_dir(dir: Vector2) -> String:
	match dir:
		Vector2.RIGHT: return "Right"
		Vector2.UP: return "Up"
		Vector2.DOWN: return "Down"
		Vector2.LEFT: return "Left"
		_: return "Down"
