class_name GridCamera
extends Camera2D

const DEFAULT_LIMIT_RECT = Rect2(-10000000, -10000000, 10000000, 10000000)
const CELL_SIZE = Vector2(256, 144)
const VIEWPORT_SIZE = Vector2(256, 144)
const SCROLL_DURATION = 0.5

var scrolling := false

@export var target : Player

var grid_position: Vector2:
	get: return world_to_grid(position)
var limit_rect := DEFAULT_LIMIT_RECT: 
	set = setLimitRect

@onready var last_grid_position: Vector2 = world_to_grid(target.position)

# Initialize the camera and set its initial limit_rect
func _ready() -> void:
	var origin: Vector2 = last_grid_position * CELL_SIZE
	limit_rect = Rect2(origin, origin + CELL_SIZE)


# Update the camera's position and scroll if necessary
func _physics_process(_delta: float) -> void:
	position = target.position
	
	CheckPlayerOffScreen(target.TopPos.global_position)
	CheckPlayerOffScreen(target.RightPos.global_position)
	CheckPlayerOffScreen(target.BottomPos.global_position)
	CheckPlayerOffScreen(target.LeftPos.global_position)

# check for the player
func CheckPlayerOffScreen(pos: Vector2) -> void:
	var posTarget := world_to_grid(pos)
	
	if !scrolling && posTarget != last_grid_position :
		scroll_screen(pos)
		last_grid_position = posTarget


# Set the camuras pos on new map load
func SetPos(newPos: Vector2) -> void:
	var target_origin := world_to_grid(newPos) * CELL_SIZE
	
	limit_rect = DEFAULT_LIMIT_RECT
	
	var scroll_to: Vector2 = newPos
	var scroll_to_min := target_origin + VIEWPORT_SIZE / 2
	var scroll_to_max := target_origin + CELL_SIZE - VIEWPORT_SIZE / 2
	
	scroll_to.x = clamp(scroll_to.x, scroll_to_min.x, scroll_to_max.x)
	scroll_to.y = clamp(scroll_to.y, scroll_to_min.y, scroll_to_max.y)
	
	position = scroll_to
	limit_rect = Rect2(target_origin, target_origin + CELL_SIZE)

# Scroll the camera smoothly to the new position
func scroll_screen(targetPos: Vector2) -> void:
	EventBus.CamScrollStarted.emit()
	scrolling = true
	set_physics_process(false)
	
	var target_origin := world_to_grid(targetPos) * CELL_SIZE
	var scroll_from := get_screen_center_position()
	
	limit_rect = DEFAULT_LIMIT_RECT
	
	var scroll_to := targetPos
	var scroll_to_min := target_origin + VIEWPORT_SIZE / 2
	var scroll_to_max := target_origin + CELL_SIZE - VIEWPORT_SIZE / 2
	
	scroll_to.x = clamp(scroll_to.x, scroll_to_min.x, scroll_to_max.x)
	scroll_to.y = clamp(scroll_to.y, scroll_to_min.y, scroll_to_max.y)
	
	position = scroll_from
	
	var tween := create_tween()
	tween.tween_property(self, "position", scroll_to, SCROLL_DURATION)
	
	await tween.finished
	
	limit_rect = Rect2i(target_origin, target_origin + CELL_SIZE)
	EventBus.CamScrollCompleted.emit()
	scrolling = false
	set_physics_process(true)


func setLimitRect(rect: Rect2i) -> Rect2:
	limit_left = rect.position.x
	limit_right = rect.size.x
	limit_top = rect.position.y
	limit_bottom = rect.size.y
	
	return rect


func world_to_grid(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x/CELL_SIZE.x), floor(pos.y/CELL_SIZE.y))
