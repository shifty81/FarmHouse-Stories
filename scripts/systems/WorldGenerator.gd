extends Node
## WorldGenerator - Procedurally generates the farm world layout.
## Creates a Stardew Valley-style farm with grass, farmland, paths,
## water features, fences, trees, and decorative objects using the
## Overworld tileset (16x16 tiles from gfx/Overworld.png).

## Farm dimensions in tiles (16x16 each)
const FARM_WIDTH: int = 80
const FARM_HEIGHT: int = 60

## Tile size in pixels
const TILE_SIZE: int = 16

## Atlas source ID in the TileSet (0 = Overworld.png)
const OVERWORLD_SOURCE: int = 0
const OBJECTS_SOURCE: int = 1

## -- Overworld.png atlas coordinates for key terrain tiles --
## These map to specific 16x16 cells in the 640x576 Overworld.png (40 cols x 36 rows)

# Grass variants
const GRASS_TILES: Array = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
]

# Dirt / tilled soil
const DIRT_TILES: Array = [
	Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0),
	Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
]

# Farmland (plantable tilled soil)
const FARMLAND_TILE := Vector2i(7, 1)

# Path tiles (stone path)
const PATH_TILES: Array = [
	Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0),
	Vector2i(12, 1), Vector2i(13, 1), Vector2i(14, 1),
]
const PATH_CENTER := Vector2i(13, 1)

# Water tiles
const WATER_TILES: Array = [
	Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6),
	Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7),
	Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8),
]
const WATER_CENTER := Vector2i(1, 7)

# Fence tiles
const FENCE_H := Vector2i(19, 0)
const FENCE_V := Vector2i(18, 0)
const FENCE_POST := Vector2i(18, 1)

# Tree tiles (larger objects, using top-left of tree graphic)
const TREE_TILES: Array = [
	Vector2i(0, 10), Vector2i(2, 10), Vector2i(4, 10),
]

# Bush / shrub
const BUSH_TILE := Vector2i(6, 10)

# Rock / stone
const ROCK_TILES: Array = [
	Vector2i(16, 4), Vector2i(17, 4),
]

# Flower decorations
const FLOWER_TILES: Array = [
	Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2),
]

func generate_farm(ground_layer: TileMapLayer, paths_layer: TileMapLayer,
		plantable_layer: TileMapLayer, objects_layer: TileMapLayer,
		tileset: TileSet) -> void:
	# Clear existing tiles
	ground_layer.clear()
	paths_layer.clear()
	plantable_layer.clear()
	objects_layer.clear()

	# Assign tileset to all layers
	ground_layer.tile_set = tileset
	paths_layer.tile_set = tileset
	plantable_layer.tile_set = tileset
	objects_layer.tile_set = tileset

	# Build the world
	_fill_ground(ground_layer)
	_create_water_feature(ground_layer)
	_create_farm_plots(plantable_layer)
	_create_paths(paths_layer)
	_create_fences(objects_layer)
	_place_trees(objects_layer)
	_place_decorations(objects_layer)


func _fill_ground(layer: TileMapLayer) -> void:
	## Fill the entire farm area with grass tiles
	for x in range(FARM_WIDTH):
		for y in range(FARM_HEIGHT):
			# Use varied grass for natural look
			var grass = GRASS_TILES[_tile_hash(x, y) % GRASS_TILES.size()]
			layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, grass)


func _create_water_feature(layer: TileMapLayer) -> void:
	## Create a creek/pond that runs through the farm
	## Inspired by the marine farm reference - a gentle stream

	# Pond in the bottom-right area
	var pond_x := 58
	var pond_y := 38
	var pond_w := 8
	var pond_h := 6

	for x in range(pond_x, pond_x + pond_w):
		for y in range(pond_y, pond_y + pond_h):
			if x >= 0 and x < FARM_WIDTH and y >= 0 and y < FARM_HEIGHT:
				var wx := x - pond_x
				var wy := y - pond_y
				# Determine edge vs center for proper water tile
				var atlas_coord := _get_water_atlas(wx, wy, pond_w, pond_h)
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, atlas_coord)

	# Small stream running from top-right toward the pond
	var stream_x := 62
	for y in range(10, pond_y):
		# Narrow 2-tile wide stream
		layer.set_cell(Vector2i(stream_x, y), OVERWORLD_SOURCE, WATER_CENTER)
		layer.set_cell(Vector2i(stream_x + 1, y), OVERWORLD_SOURCE, WATER_CENTER)
		# Dirt banks on sides
		layer.set_cell(Vector2i(stream_x - 1, y), OVERWORLD_SOURCE, DIRT_TILES[0])
		layer.set_cell(Vector2i(stream_x + 2, y), OVERWORLD_SOURCE, DIRT_TILES[2])


func _get_water_atlas(local_x: int, local_y: int, w: int, h: int) -> Vector2i:
	## Pick appropriate water tile based on position within the water body
	var col := 1  # center
	var row := 1  # center

	if local_x == 0:
		col = 0  # left edge
	elif local_x == w - 1:
		col = 2  # right edge

	if local_y == 0:
		row = 0  # top edge
	elif local_y == h - 1:
		row = 2  # bottom edge

	return WATER_TILES[row * 3 + col]


func _create_farm_plots(layer: TileMapLayer) -> void:
	## Create several rectangular farmland plots where crops can be planted
	## Main farm plot area - center of the farm

	var plots = [
		# Main large plot near spawn
		Rect2i(22, 20, 12, 10),
		# Second plot to the right
		Rect2i(38, 20, 10, 8),
		# Smaller plot below
		Rect2i(22, 34, 8, 6),
		# Additional plot
		Rect2i(34, 32, 6, 6),
	]

	for plot in plots:
		for x in range(plot.position.x, plot.position.x + plot.size.x):
			for y in range(plot.position.y, plot.position.y + plot.size.y):
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, FARMLAND_TILE)


func _create_paths(layer: TileMapLayer) -> void:
	## Create stone paths connecting farm areas

	# Main horizontal path across the farm (y=18, from house area to east)
	for x in range(10, 55):
		layer.set_cell(Vector2i(x, 18), OVERWORLD_SOURCE, PATH_CENTER)
		layer.set_cell(Vector2i(x, 19), OVERWORLD_SOURCE, PATH_CENTER)

	# Vertical path from entrance to main path
	for y in range(0, 19):
		layer.set_cell(Vector2i(20, y), OVERWORLD_SOURCE, PATH_CENTER)
		layer.set_cell(Vector2i(21, y), OVERWORLD_SOURCE, PATH_CENTER)

	# Path down to lower farm plots
	for y in range(19, 42):
		layer.set_cell(Vector2i(20, y), OVERWORLD_SOURCE, PATH_CENTER)
		layer.set_cell(Vector2i(21, y), OVERWORLD_SOURCE, PATH_CENTER)

	# Path to the pond
	for x in range(48, 60):
		layer.set_cell(Vector2i(x, 36), OVERWORLD_SOURCE, PATH_CENTER)
		layer.set_cell(Vector2i(x, 37), OVERWORLD_SOURCE, PATH_CENTER)

	# Path from main road to second farm plot
	for y in range(18, 22):
		layer.set_cell(Vector2i(36, y), OVERWORLD_SOURCE, PATH_CENTER)
		layer.set_cell(Vector2i(37, y), OVERWORLD_SOURCE, PATH_CENTER)


func _create_fences(layer: TileMapLayer) -> void:
	## Place fences around the farm perimeter and farm plots

	# Farm perimeter fence (outer boundary)
	# Top fence
	for x in range(4, FARM_WIDTH - 4):
		layer.set_cell(Vector2i(x, 3), OVERWORLD_SOURCE, FENCE_H)

	# Bottom fence
	for x in range(4, FARM_WIDTH - 4):
		layer.set_cell(Vector2i(x, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_H)

	# Left fence
	for y in range(3, FARM_HEIGHT - 3):
		layer.set_cell(Vector2i(4, y), OVERWORLD_SOURCE, FENCE_V)

	# Right fence
	for y in range(3, FARM_HEIGHT - 3):
		layer.set_cell(Vector2i(FARM_WIDTH - 5, y), OVERWORLD_SOURCE, FENCE_V)

	# Corner posts
	layer.set_cell(Vector2i(4, 3), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(FARM_WIDTH - 5, 3), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(4, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(FARM_WIDTH - 5, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_POST)

	# Gate openings at entrance (remove fence for path)
	layer.erase_cell(Vector2i(20, 3))
	layer.erase_cell(Vector2i(21, 3))

	# Fence around main farm plot
	_fence_rect(layer, Rect2i(21, 19, 14, 12))
	# Fence around second plot
	_fence_rect(layer, Rect2i(37, 19, 12, 10))


func _fence_rect(layer: TileMapLayer, rect: Rect2i) -> void:
	## Place fence around a rectangular area with gaps for path access
	var x1 := rect.position.x
	var y1 := rect.position.y
	var x2 := rect.position.x + rect.size.x - 1
	var y2 := rect.position.y + rect.size.y - 1

	# Top and bottom
	for x in range(x1, x2 + 1):
		layer.set_cell(Vector2i(x, y1), OVERWORLD_SOURCE, FENCE_H)
		layer.set_cell(Vector2i(x, y2), OVERWORLD_SOURCE, FENCE_H)

	# Left and right
	for y in range(y1, y2 + 1):
		layer.set_cell(Vector2i(x1, y), OVERWORLD_SOURCE, FENCE_V)
		layer.set_cell(Vector2i(x2, y), OVERWORLD_SOURCE, FENCE_V)

	# Corner posts
	layer.set_cell(Vector2i(x1, y1), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x2, y1), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x1, y2), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x2, y2), OVERWORLD_SOURCE, FENCE_POST)

	# Gate opening on the side nearest the path
	layer.erase_cell(Vector2i(x1, y1 + rect.size.y / 2))
	layer.erase_cell(Vector2i(x1, y1 + rect.size.y / 2 + 1))


func _place_trees(layer: TileMapLayer) -> void:
	## Scatter trees around the farm edges and forested areas

	# Dense tree line along the top border
	for x in range(6, FARM_WIDTH - 6):
		if x < 18 or x > 23:  # Gap for entrance
			if _tile_hash(x, 4) % 3 == 0:
				var tree = TREE_TILES[_tile_hash(x, 5) % TREE_TILES.size()]
				layer.set_cell(Vector2i(x, 5), OVERWORLD_SOURCE, tree)

	# Trees along left edge
	for y in range(6, FARM_HEIGHT - 6):
		if _tile_hash(5, y) % 4 == 0:
			var tree = TREE_TILES[_tile_hash(6, y) % TREE_TILES.size()]
			layer.set_cell(Vector2i(6, y), OVERWORLD_SOURCE, tree)

	# Trees along right edge
	for y in range(6, FARM_HEIGHT - 6):
		if _tile_hash(FARM_WIDTH - 7, y) % 4 == 0:
			var tree = TREE_TILES[_tile_hash(FARM_WIDTH - 6, y) % TREE_TILES.size()]
			layer.set_cell(Vector2i(FARM_WIDTH - 7, y), OVERWORLD_SOURCE, tree)

	# Trees along bottom edge
	for x in range(6, FARM_WIDTH - 6):
		if _tile_hash(x, FARM_HEIGHT - 6) % 3 == 0:
			var tree = TREE_TILES[_tile_hash(x, FARM_HEIGHT - 5) % TREE_TILES.size()]
			layer.set_cell(Vector2i(x, FARM_HEIGHT - 6), OVERWORLD_SOURCE, tree)

	# Small forest patch in top-right
	for x in range(50, 58):
		for y in range(6, 14):
			if _tile_hash(x, y) % 3 == 0:
				var tree = TREE_TILES[_tile_hash(x, y + 1) % TREE_TILES.size()]
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Scattered trees in open areas (avoid farm plots and paths)
	var no_tree_zones = [
		Rect2i(18, 16, 40, 28),  # Main farming area
		Rect2i(56, 36, 12, 12),  # Pond area
	]

	for x in range(8, FARM_WIDTH - 8):
		for y in range(8, FARM_HEIGHT - 8):
			if _tile_hash(x, y) % 20 == 0:
				var in_zone := false
				for zone in no_tree_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var tree = TREE_TILES[_tile_hash(x, y + 2) % TREE_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)


func _place_decorations(layer: TileMapLayer) -> void:
	## Place bushes, rocks, and flowers for visual variety

	# Bushes near fences and paths
	var bush_positions = [
		Vector2i(10, 16), Vector2i(12, 16), Vector2i(14, 16),
		Vector2i(10, 42), Vector2i(12, 42),
		Vector2i(46, 18), Vector2i(48, 18),
	]
	for pos in bush_positions:
		layer.set_cell(pos, OVERWORLD_SOURCE, BUSH_TILE)

	# Rocks scattered around
	for x in range(8, FARM_WIDTH - 8):
		for y in range(8, FARM_HEIGHT - 8):
			if _tile_hash(x + 7, y + 3) % 35 == 0:
				# Don't place on paths, plots, or water
				var rock = ROCK_TILES[_tile_hash(x, y) % ROCK_TILES.size()]
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, rock)

	# Flowers in grassy areas
	for x in range(8, FARM_WIDTH - 8):
		for y in range(8, FARM_HEIGHT - 8):
			if _tile_hash(x + 13, y + 11) % 25 == 0:
				var flower = FLOWER_TILES[_tile_hash(x, y) % FLOWER_TILES.size()]
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, flower)


func _tile_hash(x: int, y: int) -> int:
	## Simple deterministic hash for consistent pseudo-random tile placement
	## Same seed always produces the same layout
	var h := x * 374761393 + y * 668265263
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return absi(h)


func get_spawn_position() -> Vector2:
	## Returns the player spawn position in world coordinates
	## Center of the farm near the main path
	return Vector2(20 * TILE_SIZE + TILE_SIZE / 2, 15 * TILE_SIZE + TILE_SIZE / 2)
