extends Node
## WorldGenerator - Procedurally generates the farm world layout.
## Creates a Stardew Valley-style farm with grass, farmland, paths,
## water features, fences, trees, and decorative objects using the
## Overworld tileset (16x16 tiles from gfx/Overworld.png, 40 cols x 36 rows).
##
## Layout mimics Stardew Valley's starting farm:
## - Farmhouse in upper-left with a small porch area
## - Shipping bin beside the house
## - Dirt path from the farmhouse down to an open clearing
## - Overgrown fields with scattered debris (rocks, weeds, branches)
## - Cleared farmland plots near the house
## - Pond in the south-east
## - Dense tree borders on all edges
## - Exit path at the bottom leading out of the farm

## Farm dimensions in tiles (16x16 each)
const FARM_WIDTH: int = 80
const FARM_HEIGHT: int = 60

## Tile size in pixels
const TILE_SIZE: int = 16

## Atlas source ID in the TileSet (0 = Overworld.png)
const OVERWORLD_SOURCE: int = 0
const OBJECTS_SOURCE: int = 1

## -- Overworld.png atlas coordinates --

# Grass variants - base ground with natural variation
const GRASS_TILES: Array = [
	Vector2i(0, 0),   # plain dark grass
	Vector2i(0, 3),   # grass variant
	Vector2i(2, 3),   # grass variant
	Vector2i(0, 5),   # grass variant
	Vector2i(5, 9),   # uniform grass
	Vector2i(7, 9),   # uniform grass
]

# Lighter grass for cleared areas near the farmhouse
const GRASS_LIGHT := Vector2i(1, 4)   # bright center grass

# Dirt / tilled soil
const DIRT_TILES: Array[Vector2i] = [
	Vector2i(7, 1),   # medium brown
	Vector2i(8, 1),   # darker brown
	Vector2i(9, 1),   # medium brown variant
]

# Farmland (plantable tilled soil)
const FARMLAND_TILE := Vector2i(34, 17)  # solid farmland brown

# Path tiles
const PATH_CENTER := Vector2i(23, 4)  # main stone path

# Water tiles - edge transitions
const WATER_EDGE_TL := Vector2i(2, 9)
const WATER_EDGE_T  := Vector2i(3, 9)
const WATER_EDGE_TR := Vector2i(15, 9)
const WATER_EDGE_L  := Vector2i(2, 10)
const WATER_CENTER  := Vector2i(19, 0)
const WATER_EDGE_R  := Vector2i(15, 10)
const WATER_EDGE_BL := Vector2i(2, 6)
const WATER_EDGE_B  := Vector2i(3, 6)
const WATER_EDGE_BR := Vector2i(16, 8)

# Fence tiles
const FENCE_H := Vector2i(12, 4)
const FENCE_V := Vector2i(6, 4)
const FENCE_POST := Vector2i(7, 4)

# Tree tiles
const TREE_TILES: Array = [
	Vector2i(0, 11),  # dark green tree
	Vector2i(4, 11),  # tree variant
	Vector2i(5, 11),  # tree foliage variant
]

# Bush / shrub
const BUSH_TILE := Vector2i(11, 5)

# Rock / stone decorations
const ROCK_TILES: Array = [
	Vector2i(12, 3),  # dark rock
	Vector2i(13, 3),  # rock variant
]

# Flower decorations
const FLOWER_TILES: Array = [
	Vector2i(11, 6),  # flower detail
	Vector2i(12, 5),  # light green detail
	Vector2i(12, 6),  # flower variant
]

# Building tiles for farmhouse (brown wooden structure from Overworld.png)
const HOUSE_WALL := Vector2i(7, 1)       # wall fill (brown)
const HOUSE_WALL_DARK := Vector2i(8, 1)  # darker wall
const HOUSE_ROOF := Vector2i(7, 0)       # roof top (darker brown)
const HOUSE_ROOF_EDGE := Vector2i(8, 0)  # roof edge
const HOUSE_DOOR := Vector2i(8, 4)       # dark doorway
const HOUSE_WINDOW := Vector2i(12, 2)    # window tile
const HOUSE_FLOOR := Vector2i(9, 1)      # porch/floor


func generate_farm(ground_layer: TileMapLayer, paths_layer: TileMapLayer,
		plantable_layer: TileMapLayer, objects_layer: TileMapLayer,
		tileset: TileSet) -> void:
	ground_layer.clear()
	paths_layer.clear()
	plantable_layer.clear()
	objects_layer.clear()

	ground_layer.tile_set = tileset
	paths_layer.tile_set = tileset
	plantable_layer.tile_set = tileset
	objects_layer.tile_set = tileset

	_fill_ground(ground_layer)
	_create_farmhouse(objects_layer, ground_layer)
	_create_water_feature(ground_layer)
	_create_dirt_clearing(ground_layer)
	_create_farm_plots(plantable_layer)
	_create_paths(paths_layer)
	_create_farm_fences(objects_layer)
	_place_border_trees(objects_layer)
	_place_overgrown_debris(objects_layer)
	_place_decorations(objects_layer)


func _fill_ground(layer: TileMapLayer) -> void:
	## Fill entire farm with grass, using lighter grass near the farmhouse
	for x in range(FARM_WIDTH):
		for y in range(FARM_HEIGHT):
			var grass: Vector2i
			# Lighter grass in the main clearing (Stardew-style open area)
			if x >= 10 and x <= 50 and y >= 10 and y <= 45:
				if _tile_hash(x, y) % 4 == 0:
					grass = GRASS_LIGHT
				else:
					grass = GRASS_TILES[_tile_hash(x, y) % 3]  # fewer variants for uniformity
			else:
				grass = GRASS_TILES[_tile_hash(x, y) % GRASS_TILES.size()]
			layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, grass)


func _create_farmhouse(objects_layer: TileMapLayer, ground_layer: TileMapLayer) -> void:
	## Create a farmhouse building in the upper-left area (Stardew Valley style)
	## House is at roughly (10, 5) to (18, 10) with a porch below

	var hx := 10  # house left x
	var hy := 5   # house top y
	var hw := 8   # house width
	var hh := 5   # house height (walls)

	# Roof (top 2 rows of house)
	for x in range(hx, hx + hw):
		objects_layer.set_cell(Vector2i(x, hy), OVERWORLD_SOURCE, HOUSE_ROOF)
		objects_layer.set_cell(Vector2i(x, hy + 1), OVERWORLD_SOURCE, HOUSE_ROOF_EDGE)

	# Walls (middle rows)
	for x in range(hx, hx + hw):
		for y in range(hy + 2, hy + hh):
			if x == hx or x == hx + hw - 1:
				objects_layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, HOUSE_WALL_DARK)
			else:
				objects_layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, HOUSE_WALL)

	# Windows on front wall
	objects_layer.set_cell(Vector2i(hx + 2, hy + 3), OVERWORLD_SOURCE, HOUSE_WINDOW)
	objects_layer.set_cell(Vector2i(hx + 5, hy + 3), OVERWORLD_SOURCE, HOUSE_WINDOW)

	# Door in the center of the front wall
	objects_layer.set_cell(Vector2i(hx + 3, hy + 4), OVERWORLD_SOURCE, HOUSE_DOOR)
	objects_layer.set_cell(Vector2i(hx + 4, hy + 4), OVERWORLD_SOURCE, HOUSE_DOOR)

	# Porch area (dirt/stone in front of house)
	for x in range(hx, hx + hw):
		ground_layer.set_cell(Vector2i(x, hy + hh), OVERWORLD_SOURCE, DIRT_TILES[0])
		ground_layer.set_cell(Vector2i(x, hy + hh + 1), OVERWORLD_SOURCE, DIRT_TILES[1])

	# Shipping bin next to house (small brown structure)
	objects_layer.set_cell(Vector2i(hx + hw + 1, hy + hh - 1), OVERWORLD_SOURCE, HOUSE_WALL_DARK)
	objects_layer.set_cell(Vector2i(hx + hw + 2, hy + hh - 1), OVERWORLD_SOURCE, HOUSE_WALL_DARK)
	objects_layer.set_cell(Vector2i(hx + hw + 1, hy + hh), OVERWORLD_SOURCE, HOUSE_WALL)
	objects_layer.set_cell(Vector2i(hx + hw + 2, hy + hh), OVERWORLD_SOURCE, HOUSE_WALL)


func _create_dirt_clearing(ground_layer: TileMapLayer) -> void:
	## Create a natural dirt clearing around the farmhouse (like Stardew's starting area)
	## The area directly around the house is cleared dirt/path

	# Dirt area around and below the house
	var clear_rect := Rect2i(9, 10, 12, 4)
	for x in range(clear_rect.position.x, clear_rect.position.x + clear_rect.size.x):
		for y in range(clear_rect.position.y, clear_rect.position.y + clear_rect.size.y):
			var dirt := DIRT_TILES[_tile_hash(x, y) % DIRT_TILES.size()]
			ground_layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, dirt)


func _create_water_feature(layer: TileMapLayer) -> void:
	## Create a pond in the south-east (like Stardew's farm pond)
	var pond_x := 52
	var pond_y := 40
	var pond_w := 10
	var pond_h := 7

	for x in range(pond_x, pond_x + pond_w):
		for y in range(pond_y, pond_y + pond_h):
			if x >= 0 and x < FARM_WIDTH and y >= 0 and y < FARM_HEIGHT:
				var atlas_coord := _get_water_edge(x - pond_x, y - pond_y, pond_w, pond_h)
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, atlas_coord)

	# Small secondary pond in the north-west corner
	var pond2_x := 6
	var pond2_y := 42
	var pond2_w := 5
	var pond2_h := 4

	for x in range(pond2_x, pond2_x + pond2_w):
		for y in range(pond2_y, pond2_y + pond2_h):
			if x >= 0 and x < FARM_WIDTH and y >= 0 and y < FARM_HEIGHT:
				var atlas_coord := _get_water_edge(x - pond2_x, y - pond2_y, pond2_w, pond2_h)
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, atlas_coord)


func _get_water_edge(local_x: int, local_y: int, w: int, h: int) -> Vector2i:
	var is_left := local_x == 0
	var is_right := local_x == w - 1
	var is_top := local_y == 0
	var is_bottom := local_y == h - 1

	if is_top and is_left:
		return WATER_EDGE_TL
	if is_top and is_right:
		return WATER_EDGE_TR
	if is_bottom and is_left:
		return WATER_EDGE_BL
	if is_bottom and is_right:
		return WATER_EDGE_BR
	if is_top:
		return WATER_EDGE_T
	if is_bottom:
		return WATER_EDGE_B
	if is_left:
		return WATER_EDGE_L
	if is_right:
		return WATER_EDGE_R
	return WATER_CENTER


func _create_farm_plots(layer: TileMapLayer) -> void:
	## Create farmland plots near the house - cleared and ready to plant
	## Stardew style: a few small cleared plots with dirt borders

	var plots: Array[Rect2i] = [
		Rect2i(14, 16, 10, 8),   # Main plot south of house
		Rect2i(28, 16, 8, 6),    # Second plot to the east
		Rect2i(14, 28, 6, 5),    # Smaller plot further south
	]

	for plot in plots:
		for x in range(plot.position.x, plot.position.x + plot.size.x):
			for y in range(plot.position.y, plot.position.y + plot.size.y):
				var is_border_x := (x == plot.position.x or x == plot.position.x + plot.size.x - 1)
				var is_border_y := (y == plot.position.y or y == plot.position.y + plot.size.y - 1)
				if is_border_x or is_border_y:
					var dirt := DIRT_TILES[_tile_hash(x, y) % DIRT_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, dirt)
				else:
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, FARMLAND_TILE)


func _create_paths(layer: TileMapLayer) -> void:
	## Create dirt/stone paths connecting areas (Stardew-style natural paths)

	# Path from farmhouse door down to the farm area
	for y in range(12, 30):
		layer.set_cell(Vector2i(13, y), OVERWORLD_SOURCE, PATH_CENTER)
		if y < 16:
			layer.set_cell(Vector2i(14, y), OVERWORLD_SOURCE, PATH_CENTER)

	# Horizontal path connecting farm plots
	for x in range(13, 38):
		layer.set_cell(Vector2i(x, 15), OVERWORLD_SOURCE, PATH_CENTER)

	# Path heading south to farm exit
	for y in range(30, FARM_HEIGHT - 3):
		layer.set_cell(Vector2i(13, y), OVERWORLD_SOURCE, PATH_CENTER)

	# Short path east toward the pond
	for x in range(36, 52):
		layer.set_cell(Vector2i(x, 38), OVERWORLD_SOURCE, PATH_CENTER)

	# Path from second plot down
	for y in range(22, 38):
		layer.set_cell(Vector2i(32, y), OVERWORLD_SOURCE, PATH_CENTER)


func _create_farm_fences(layer: TileMapLayer) -> void:
	## Place fences around farm plots and a perimeter fence with gate openings

	# Fence around main farm plot
	_fence_rect(layer, Rect2i(13, 15, 12, 10))
	# Fence around second plot
	_fence_rect(layer, Rect2i(27, 15, 10, 8))

	# Partial perimeter fence along edges (with gaps for exits)
	# Top fence
	for x in range(5, FARM_WIDTH - 5):
		if x < 12 or x > 15:  # Gap for entrance
			layer.set_cell(Vector2i(x, 3), OVERWORLD_SOURCE, FENCE_H)

	# Bottom fence with exit gap
	for x in range(5, FARM_WIDTH - 5):
		if x < 12 or x > 14:  # Gap for exit
			layer.set_cell(Vector2i(x, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_H)

	# Left fence
	for y in range(3, FARM_HEIGHT - 3):
		layer.set_cell(Vector2i(5, y), OVERWORLD_SOURCE, FENCE_V)

	# Right fence
	for y in range(3, FARM_HEIGHT - 3):
		layer.set_cell(Vector2i(FARM_WIDTH - 5, y), OVERWORLD_SOURCE, FENCE_V)

	# Corner posts
	layer.set_cell(Vector2i(5, 3), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(FARM_WIDTH - 5, 3), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(5, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(FARM_WIDTH - 5, FARM_HEIGHT - 4), OVERWORLD_SOURCE, FENCE_POST)


func _fence_rect(layer: TileMapLayer, rect: Rect2i) -> void:
	var x1 := rect.position.x
	var y1 := rect.position.y
	var x2 := rect.position.x + rect.size.x - 1
	var y2 := rect.position.y + rect.size.y - 1

	for x in range(x1, x2 + 1):
		layer.set_cell(Vector2i(x, y1), OVERWORLD_SOURCE, FENCE_H)
		layer.set_cell(Vector2i(x, y2), OVERWORLD_SOURCE, FENCE_H)

	for y in range(y1, y2 + 1):
		layer.set_cell(Vector2i(x1, y), OVERWORLD_SOURCE, FENCE_V)
		layer.set_cell(Vector2i(x2, y), OVERWORLD_SOURCE, FENCE_V)

	layer.set_cell(Vector2i(x1, y1), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x2, y1), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x1, y2), OVERWORLD_SOURCE, FENCE_POST)
	layer.set_cell(Vector2i(x2, y2), OVERWORLD_SOURCE, FENCE_POST)

	# Gate opening on the south side
	layer.erase_cell(Vector2i(x1 + rect.size.x / 2, y2))
	layer.erase_cell(Vector2i(x1 + rect.size.x / 2 + 1, y2))


func _place_border_trees(layer: TileMapLayer) -> void:
	## Dense tree borders on all edges (Stardew Valley style thick forest borders)

	# Exclusion zones where trees should not be placed
	var no_tree_zones: Array[Rect2i] = [
		Rect2i(9, 4, 12, 9),    # Farmhouse area
		Rect2i(12, 13, 28, 16), # Farm plots area
		Rect2i(12, 29, 8, 10),  # Lower path area
		Rect2i(50, 38, 14, 12), # Pond area
		Rect2i(4, 40, 9, 8),    # Second pond area
	]

	# Top border - 3 rows of dense trees
	for x in range(3, FARM_WIDTH - 3):
		for y in range(0, 4):
			if x < 12 or x > 15 or y < 2:  # Gap for entrance
				var tree = TREE_TILES[_tile_hash(x, y) % TREE_TILES.size()]
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Bottom border
	for x in range(3, FARM_WIDTH - 3):
		for y in range(FARM_HEIGHT - 3, FARM_HEIGHT):
			if x < 12 or x > 14:  # Gap for exit
				var tree = TREE_TILES[_tile_hash(x, y) % TREE_TILES.size()]
				layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Left border - 2 rows
	for y in range(0, FARM_HEIGHT):
		for x in range(0, 5):
			var tree = TREE_TILES[_tile_hash(x, y) % TREE_TILES.size()]
			layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Right border - 2 rows
	for y in range(0, FARM_HEIGHT):
		for x in range(FARM_WIDTH - 4, FARM_WIDTH):
			var tree = TREE_TILES[_tile_hash(x, y) % TREE_TILES.size()]
			layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Forest patch in upper-right (overgrown area)
	for x in range(45, 60):
		for y in range(5, 16):
			if _tile_hash(x, y) % 3 != 0:  # Dense but not 100%
				var in_zone := false
				for zone in no_tree_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var tree = TREE_TILES[_tile_hash(x, y + 1) % TREE_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# Scattered trees in the overgrown south area
	for x in range(6, FARM_WIDTH - 6):
		for y in range(30, FARM_HEIGHT - 5):
			if _tile_hash(x, y) % 8 == 0:
				var in_zone := false
				for zone in no_tree_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var tree = TREE_TILES[_tile_hash(x, y + 2) % TREE_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)

	# A few trees scattered in the main farm area (overgrown, Stardew start)
	for x in range(20, 45):
		for y in range(16, 30):
			if _tile_hash(x, y) % 18 == 0:
				var in_zone := false
				for zone in no_tree_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var tree = TREE_TILES[_tile_hash(x, y + 3) % TREE_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, tree)


func _place_overgrown_debris(layer: TileMapLayer) -> void:
	## Scatter rocks, weeds, and bushes across the farm (Stardew overgrown start)
	## The farm starts cluttered - player will need to clear it

	var no_debris_zones: Array[Rect2i] = [
		Rect2i(9, 4, 12, 10),   # Farmhouse and porch
		Rect2i(12, 14, 12, 11), # Main farm plot
		Rect2i(26, 14, 12, 10), # Second farm plot
		Rect2i(50, 38, 14, 12), # Pond
		Rect2i(4, 40, 9, 8),    # Second pond
	]

	# Rocks scattered around the overgrown farm
	for x in range(6, FARM_WIDTH - 6):
		for y in range(6, FARM_HEIGHT - 6):
			if _tile_hash(x + 7, y + 3) % 20 == 0:
				var in_zone := false
				for zone in no_debris_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var rock = ROCK_TILES[_tile_hash(x, y) % ROCK_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, rock)

	# Bushes/weeds scattered more densely
	for x in range(6, FARM_WIDTH - 6):
		for y in range(6, FARM_HEIGHT - 6):
			if _tile_hash(x + 11, y + 5) % 15 == 0:
				var in_zone := false
				for zone in no_debris_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, BUSH_TILE)


func _place_decorations(layer: TileMapLayer) -> void:
	## Place flowers in grassy areas for visual variety

	var no_deco_zones: Array[Rect2i] = [
		Rect2i(9, 4, 12, 10),
		Rect2i(50, 38, 14, 12),
		Rect2i(4, 40, 9, 8),
	]

	for x in range(8, FARM_WIDTH - 8):
		for y in range(8, FARM_HEIGHT - 8):
			if _tile_hash(x + 13, y + 11) % 30 == 0:
				var in_zone := false
				for zone in no_deco_zones:
					if zone.has_point(Vector2i(x, y)):
						in_zone = true
						break
				if not in_zone:
					var flower = FLOWER_TILES[_tile_hash(x, y) % FLOWER_TILES.size()]
					layer.set_cell(Vector2i(x, y), OVERWORLD_SOURCE, flower)


func _tile_hash(x: int, y: int) -> int:
	## Simple deterministic hash for consistent pseudo-random tile placement
	var h := x * 374761393 + y * 668265263
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return absi(h)


func get_spawn_position() -> Vector2:
	## Returns the player spawn position in world coordinates
	## In front of the farmhouse door (Stardew Valley style)
	return Vector2(14 * TILE_SIZE, 12 * TILE_SIZE)
