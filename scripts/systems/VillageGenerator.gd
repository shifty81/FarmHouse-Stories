extends RefCounted
## VillageGenerator - Procedurally generates village layouts within world chunks.
## Villages consist of a central well/plaza, surrounding houses with doors and
## windows, connecting paths, and perimeter fences. Structure sizes vary by biome.
##
## Used by OverworldGenerator when a "village" structure type is placed.

## Building footprint (width x height in tiles) for small/medium/large houses
const HOUSE_SMALL := Vector2i(5, 4)
const HOUSE_MEDIUM := Vector2i(7, 5)
const HOUSE_LARGE := Vector2i(9, 6)

## Village radius in tiles from center
const VILLAGE_RADIUS: int = 12

## Minimum spacing between buildings (tiles)
const BUILDING_GAP: int = 3

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func generate_village(center: Vector2i, biome: String, seed_value: int) -> Dictionary:
	## Generates a village layout centered at the given tile position.
	## Returns a dictionary with:
	##   "ground_tiles": { Vector2i -> String } - ground type overrides
	##   "object_tiles": { Vector2i -> String } - objects placed (buildings, fences)
	##   "collision_tiles": Array[Vector2i] - tiles that block movement
	##   "bounds": Rect2i - bounding rectangle of the village
	_rng.seed = seed_value

	var ground: Dictionary = {}
	var objects: Dictionary = {}
	var collision: Array[Vector2i] = []

	# --- Central plaza ---
	var plaza_radius: int = 3
	for dx in range(-plaza_radius, plaza_radius + 1):
		for dy in range(-plaza_radius, plaza_radius + 1):
			if dx * dx + dy * dy <= plaza_radius * plaza_radius:
				ground[Vector2i(center.x + dx, center.y + dy)] = "stone"

	# Well at dead center
	objects[center] = "well"
	collision.append(center)

	# --- Place buildings around plaza ---
	var building_count: int = _rng.randi_range(3, 6)
	var placed_rects: Array[Rect2i] = []

	# Reserve plaza area
	placed_rects.append(Rect2i(
		center.x - plaza_radius - 1,
		center.y - plaza_radius - 1,
		plaza_radius * 2 + 3,
		plaza_radius * 2 + 3))

	for i in range(building_count):
		var house_size: Vector2i
		var roll := _rng.randf()
		if roll < 0.3:
			house_size = HOUSE_LARGE
		elif roll < 0.7:
			house_size = HOUSE_MEDIUM
		else:
			house_size = HOUSE_SMALL

		# Try to place building at a valid position
		for _attempt in range(20):
			var angle: float = _rng.randf() * TAU
			var dist: float = _rng.randf_range(plaza_radius + BUILDING_GAP + 1, VILLAGE_RADIUS - 2)
			var bx := center.x + int(cos(angle) * dist) - house_size.x / 2
			var by := center.y + int(sin(angle) * dist) - house_size.y / 2

			var candidate := Rect2i(bx - 1, by - 1, house_size.x + 2, house_size.y + 2)
			var overlaps := false
			for existing: Rect2i in placed_rects:
				if candidate.intersects(existing):
					overlaps = true
					break
			if overlaps:
				continue

			# Place the building
			_place_building(bx, by, house_size, objects, collision, ground)
			placed_rects.append(candidate)

			# Path from building door to plaza
			var door_x := bx + house_size.x / 2
			var door_y := by + house_size.y
			_place_path(Vector2i(door_x, door_y), center, ground)
			break

	# --- Perimeter fence with gaps at paths ---
	_place_village_fence(center, VILLAGE_RADIUS, ground, objects, collision)

	# --- Decorations (signposts, flowers) ---
	_place_village_decorations(center, plaza_radius, VILLAGE_RADIUS, biome, objects, ground)

	var bounds := Rect2i(
		center.x - VILLAGE_RADIUS,
		center.y - VILLAGE_RADIUS,
		VILLAGE_RADIUS * 2,
		VILLAGE_RADIUS * 2)

	return {
		"ground_tiles": ground,
		"object_tiles": objects,
		"collision_tiles": collision,
		"bounds": bounds,
		"center": center
	}


func _place_building(bx: int, by: int, size: Vector2i,
		objects: Dictionary, collision: Array[Vector2i],
		ground: Dictionary) -> void:
	## Places a single building with walls, roof, door, and windows.

	# Roof (top row)
	for x in range(bx, bx + size.x):
		objects[Vector2i(x, by)] = "roof"
		collision.append(Vector2i(x, by))

	# Walls (sides and back)
	for y in range(by + 1, by + size.y):
		for x in range(bx, bx + size.x):
			var is_edge := (x == bx or x == bx + size.x - 1)
			var is_front := (y == by + size.y - 1)

			if is_front:
				# Front wall with door in center
				var door_x := bx + size.x / 2
				if x == door_x:
					objects[Vector2i(x, y)] = "door"
					# Door tile is walkable - add dirt ground under it
					ground[Vector2i(x, y)] = "dirt"
				else:
					objects[Vector2i(x, y)] = "wall"
					collision.append(Vector2i(x, y))
			elif is_edge:
				objects[Vector2i(x, y)] = "wall_dark"
				collision.append(Vector2i(x, y))
			else:
				# Interior - mark as wall (not walkable through)
				objects[Vector2i(x, y)] = "wall"
				collision.append(Vector2i(x, y))

	# Windows on front wall (if building is wide enough)
	if size.x >= 5:
		var front_y := by + size.y - 2
		objects[Vector2i(bx + 1, front_y)] = "window"
		if size.x >= 7:
			objects[Vector2i(bx + size.x - 2, front_y)] = "window"

	# Floor area in front of door
	var door_x := bx + size.x / 2
	ground[Vector2i(door_x, by + size.y)] = "dirt"


func _place_path(from: Vector2i, to: Vector2i, ground: Dictionary) -> void:
	## Places a simple L-shaped path of stone tiles between two points.
	var cx := from.x
	var cy := from.y
	var step_x := 1 if to.x > cx else -1
	var step_y := 1 if to.y > cy else -1

	# Walk horizontally first, then vertically
	while cx != to.x:
		ground[Vector2i(cx, cy)] = "stone"
		cx += step_x
	while cy != to.y:
		ground[Vector2i(cx, cy)] = "stone"
		cy += step_y
	ground[Vector2i(cx, cy)] = "stone"


func _place_village_fence(center: Vector2i, radius: int,
		ground: Dictionary, objects: Dictionary,
		collision: Array[Vector2i]) -> void:
	## Places a loose fence ring around the village with gaps at cardinal directions.
	var gap_half: int = 2
	for dx in range(-radius, radius + 1):
		for dy in [-radius, radius]:
			var pos := Vector2i(center.x + dx, center.y + dy)
			# Leave gaps at cardinal directions
			if abs(dx) <= gap_half:
				ground[pos] = "dirt"
				continue
			objects[pos] = "fence"
			collision.append(pos)

	for dy in range(-radius + 1, radius):
		for dx in [-radius, radius]:
			var pos := Vector2i(center.x + dx, center.y + dy)
			if abs(dy) <= gap_half:
				ground[pos] = "dirt"
				continue
			objects[pos] = "fence"
			collision.append(pos)


func _place_village_decorations(center: Vector2i, plaza_radius: int,
		village_radius: int, _biome: String,
		objects: Dictionary, ground: Dictionary) -> void:
	## Adds decorative elements: signpost near entrance, flowers around plaza.
	# Signpost at south entrance
	var sign_pos := Vector2i(center.x + 1, center.y + village_radius + 1)
	objects[sign_pos] = "signpost"

	# Flower patches around the plaza
	for i in range(4):
		var angle: float = _rng.randf() * TAU
		var dist: float = _rng.randf_range(plaza_radius + 1, plaza_radius + 3)
		var fx := center.x + int(cos(angle) * dist)
		var fy := center.y + int(sin(angle) * dist)
		var pos := Vector2i(fx, fy)
		if not objects.has(pos):
			objects[pos] = "flower"
			ground[pos] = "grass"
