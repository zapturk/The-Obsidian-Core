# dungeon_generator.gd
extends Node

const GRID_SIZE = 11
const MIN_ROOMS = 7
const MAX_ROOMS = 10
const ROOM_WIDTH = 256
const ROOM_HEIGHT = 144

@export var room_scene: PackedScene = preload("res://Scense/Rooms/Basic.tscn")

# Directions: Up, Down, Left, Right
const DIRS = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var dungeon_grid = {} # Dictionary holding Vector2i keys and room data values

func _ready() -> void:
	spawn_dungeon(generate_floor())

func generate_floor():
	var retry = 0
	var max_retries = 100
	
	while true:
		dungeon_grid.clear()
		
		# Start with the initial room at the center of our data grid
		var start_pos = Vector2i(0, 0)
		dungeon_grid[start_pos] = {"type": "START"}
		
		var room_queue = [start_pos]
		var total_rooms = randi_range(MIN_ROOMS, MAX_ROOMS)
		
		while dungeon_grid.size() < total_rooms and room_queue.size() > 0:
			var current_pos = room_queue.pick_random()
			# If this room already has too many neighbors, move on to keep it linear
			if count_neighbors(current_pos) > 2 and current_pos != start_pos:
				room_queue.erase(current_pos)
				continue
			
			var random_dir = DIRS.pick_random()
			var target_pos = current_pos + random_dir
			
			# Check boundaries and if space is empty
			if not dungeon_grid.has(target_pos) and count_neighbors(target_pos) <= 1:
				# Random chance to actually place it to create branches
				if randf() > 0.4:
					dungeon_grid[target_pos] = {"type": "NORMAL"}
					room_queue.append(target_pos)
		
		if dungeon_grid.size() >= MIN_ROOMS:
			assign_special_rooms()
			return dungeon_grid
		
		retry += 1
		if retry >= max_retries:
			# Hard fallback: force-fill remaining slots with NORMAL rooms
			# so the game never gets stuck in an impossible state.
			dungeon_grid.clear()
			start_pos = Vector2i(0, 0)
			dungeon_grid[start_pos] = {"type": "START"}
			for i in range(MIN_ROOMS - 1):
				dungeon_grid[Vector2i(i, 0)] = {"type": "NORMAL"}
			assign_special_rooms()
			return dungeon_grid

func count_neighbors(pos: Vector2i) -> int:
	var count = 0
	for d in DIRS:
		if dungeon_grid.has(pos + d):
			count += 1
	return count
	
func spawn_dungeon(grid_data: Dictionary):
	for pos in grid_data.keys():
		var room_data = grid_data[pos]
		var new_room = room_scene.instantiate()
		
		# Set real-world position
		new_room.position = Vector2(pos.x * ROOM_WIDTH, pos.y * ROOM_HEIGHT)
		add_child(new_room)
		
		# Check who surrounds this room to open the right doors
		var neighbors = []
		for d in DIRS:
			if grid_data.has(pos + d):
				neighbors.append(d)
				
		new_room.setup_doors(neighbors)
		
		# Apply cosmetics/special themes based on room_data["type"]
		if room_data["type"] == "BOSS":
			new_room.modulate = Color.CRIMSON # Simple visual tell for testing!
		
		# Name each monster uniquely based on room position
		var monster = new_room.get_node("Monster")
		if monster != null:
			monster.my_name = "Monster@" + str(pos.x) + "," + str(pos.y)
			
func assign_special_rooms():
	var dead_ends = []
	
	# 1. Find all dead ends (rooms with exactly 1 neighbor)
	for pos in dungeon_grid.keys():
		# Skip the starting room; we don't want it becoming a Boss room!
		if pos == Vector2i(0, 0):
			continue
			
		if count_neighbors(pos) == 1:
			dead_ends.append(pos)
			
	# Edge case safety: If the layout is a straight line, we might have very few dead ends.
	# If we have no dead ends, we fallback to any room that isn't the start.
	if dead_ends.is_empty():
		dead_ends = dungeon_grid.keys()
		dead_ends.erase(Vector2i(0,0))

	# 2. Find the dead end furthest away from the start room (0,0) for the Boss
	var boss_pos = dead_ends[0]
	var max_distance = 0
	
	for pos in dead_ends:
		# Manhattan distance formula: |x| + |y|
		var distance = abs(pos.x) + abs(pos.y)
		if distance > max_distance:
			max_distance = distance
			boss_pos = pos
			
	# Assign the Boss room and remove it from our pool of available dead ends
	dungeon_grid[boss_pos]["type"] = "BOSS"
	dead_ends.erase(boss_pos)
	
	# 3. Assign the Item Room from the remaining dead ends
	if not dead_ends.is_empty():
		var item_pos = dead_ends.pick_random()
		dungeon_grid[item_pos]["type"] = "ITEM"
		dead_ends.erase(item_pos)
		
	# 4. Assign the Shop Room
	if not dead_ends.is_empty():
		# If we still have a dead end left, use it for the Shop
		var shop_pos = dead_ends.pick_random()
		dungeon_grid[shop_pos]["type"] = "SHOP"
		dead_ends.erase(shop_pos)
	else:
		# If we ran out of dead ends, look for any regular room to turn into a Shop
		var fallback_rooms = []
		for pos in dungeon_grid.keys():
			if dungeon_grid[pos]["type"] == "NORMAL" and pos != Vector2i(0,0):
				fallback_rooms.append(pos)
				
		if not fallback_rooms.is_empty():
			dungeon_grid[fallback_rooms.pick_random()]["type"] = "SHOP"
