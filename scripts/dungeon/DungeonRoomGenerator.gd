extends RefCounted
## DungeonRoomGenerator - Generates tile layouts for dungeon rooms.
## Uses DungeonTilesetBuilder atlas coordinates to create
## procedural room layouts with walls, floors, and features.

const TB = preload(
	"res://scripts/dungeon/DungeonTilesetBuilder.gd")

## Room dimensions in tiles
const ROOM_WIDTH: int = 20
const ROOM_HEIGHT: int = 15


static func generate_room(
		tilemap: TileMap,
		room_type: int,
		doors: Dictionary,
		seed_val: int) -> void:
	tilemap.clear()
	var tileset := TB.build_tileset()
	tilemap.tile_set = tileset

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val

	_fill_floor(tilemap)
	_build_walls(tilemap)
	_place_doors(tilemap, doors)
	_place_features(tilemap, room_type, rng)


static func _fill_floor(tilemap: TileMap) -> void:
	for x in range(1, ROOM_WIDTH - 1):
		for y in range(1, ROOM_HEIGHT - 1):
			var tile: Vector2i
			if (x + y) % 7 == 0:
				tile = TB.FLOOR_ALT
			else:
				tile = TB.FLOOR_CENTER
			tilemap.set_cell(0, Vector2i(x, y),
				TB.CAVE_SOURCE, tile)


static func _build_walls(tilemap: TileMap) -> void:
	# Top and bottom walls
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(
			0, Vector2i(x, 0),
			TB.CAVE_SOURCE, TB.WALL_TOP)
		tilemap.set_cell(
			0, Vector2i(x, ROOM_HEIGHT - 1),
			TB.CAVE_SOURCE, TB.WALL_BOTTOM)

	# Left and right walls
	for y in range(ROOM_HEIGHT):
		tilemap.set_cell(
			0, Vector2i(0, y),
			TB.CAVE_SOURCE, TB.WALL_LEFT)
		tilemap.set_cell(
			0, Vector2i(ROOM_WIDTH - 1, y),
			TB.CAVE_SOURCE, TB.WALL_RIGHT)

	# Corners
	tilemap.set_cell(
		0, Vector2i(0, 0),
		TB.CAVE_SOURCE, TB.WALL_TL)
	tilemap.set_cell(
		0, Vector2i(ROOM_WIDTH - 1, 0),
		TB.CAVE_SOURCE, TB.WALL_TR)
	tilemap.set_cell(
		0, Vector2i(0, ROOM_HEIGHT - 1),
		TB.CAVE_SOURCE, TB.WALL_BL)
	tilemap.set_cell(
		0, Vector2i(ROOM_WIDTH - 1, ROOM_HEIGHT - 1),
		TB.CAVE_SOURCE, TB.WALL_BR)


static func _place_doors(
		tilemap: TileMap, doors: Dictionary) -> void:
	var mid_x := ROOM_WIDTH / 2
	var mid_y := ROOM_HEIGHT / 2

	if doors.get("north", false):
		tilemap.set_cell(
			0, Vector2i(mid_x, 0),
			TB.CAVE_SOURCE, TB.DOOR_H)
		tilemap.set_cell(
			0, Vector2i(mid_x - 1, 0),
			TB.CAVE_SOURCE, TB.DOOR_H)
	if doors.get("south", false):
		tilemap.set_cell(
			0, Vector2i(mid_x, ROOM_HEIGHT - 1),
			TB.CAVE_SOURCE, TB.DOOR_H)
		tilemap.set_cell(
			0, Vector2i(mid_x - 1, ROOM_HEIGHT - 1),
			TB.CAVE_SOURCE, TB.DOOR_H)
	if doors.get("west", false):
		tilemap.set_cell(
			0, Vector2i(0, mid_y),
			TB.CAVE_SOURCE, TB.DOOR_V)
		tilemap.set_cell(
			0, Vector2i(0, mid_y - 1),
			TB.CAVE_SOURCE, TB.DOOR_V)
	if doors.get("east", false):
		tilemap.set_cell(
			0, Vector2i(ROOM_WIDTH - 1, mid_y),
			TB.CAVE_SOURCE, TB.DOOR_V)
		tilemap.set_cell(
			0, Vector2i(ROOM_WIDTH - 1, mid_y - 1),
			TB.CAVE_SOURCE, TB.DOOR_V)


static func _place_features(
		tilemap: TileMap,
		room_type: int,
		rng: RandomNumberGenerator) -> void:
	# 0=ENTRANCE, 1=COMBAT, 2=PUZZLE, 3=TREASURE,
	# 4=KEY, 5=BOSS, 6=CORRIDOR, 7=TRAP
	match room_type:
		3:  # TREASURE
			tilemap.set_cell(
				0, Vector2i(ROOM_WIDTH / 2,
					ROOM_HEIGHT / 2),
				TB.CAVE_SOURCE, TB.CHEST)
		0:  # ENTRANCE
			tilemap.set_cell(
				0, Vector2i(ROOM_WIDTH / 2,
					ROOM_HEIGHT / 2),
				TB.CAVE_SOURCE, TB.STAIRS)
		_:
			_scatter_rocks(tilemap, room_type, rng)

	# Torches on walls for most rooms
	if room_type != 6:  # Not corridors
		tilemap.set_cell(
			0, Vector2i(2, 1),
			TB.CAVE_SOURCE, TB.TORCH)
		tilemap.set_cell(
			0, Vector2i(ROOM_WIDTH - 3, 1),
			TB.CAVE_SOURCE, TB.TORCH)


static func _scatter_rocks(
		tilemap: TileMap,
		room_type: int,
		rng: RandomNumberGenerator) -> void:
	var count := 0
	match room_type:
		1: count = rng.randi_range(2, 5)   # COMBAT
		2: count = rng.randi_range(3, 6)   # PUZZLE
		5: count = rng.randi_range(1, 3)   # BOSS
		7: count = rng.randi_range(4, 8)   # TRAP
		_: count = rng.randi_range(0, 2)

	for _i in range(count):
		var rx := rng.randi_range(3, ROOM_WIDTH - 4)
		var ry := rng.randi_range(3, ROOM_HEIGHT - 4)
		tilemap.set_cell(
			0, Vector2i(rx, ry),
			TB.CAVE_SOURCE, TB.ROCK)
