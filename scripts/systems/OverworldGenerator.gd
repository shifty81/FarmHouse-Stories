extends Node
## OverworldGenerator - Main world generation orchestrator.
## Combines techniques from Necesse and Core Keeper to produce a rich overworld:
##
## From Necesse:
##   - Layered generation (base terrain → biomes → rivers → details → structures)
##   - Rule-based biome adjacency to ensure natural transitions
##   - Seamless chunk-based streaming for on-demand infinite world
##   - Decorative detailing through additional noise layers
##
## From Core Keeper:
##   - Radial zone layout: biomes arranged in concentric rings from a central hub
##   - Wavy, irregular biome boundaries using noise-based edge blending
##   - Seed-based deterministic generation for reproducibility
##   - Key locations placed at specific distances/angles from the center
##   - Cave/tunnel networks carved through terrain with cellular techniques
##
## The generator produces chunk data consumed by ChunkManager and rendered via
## TileMapLayer nodes.

const NoiseGeneratorScript = preload("res://scripts/systems/NoiseGenerator.gd")

## World seed for deterministic generation
var world_seed: int = 0

## Noise utility instance
var noise_gen: RefCounted = null

## World center in tile coordinates (player hub / farm).
## Matches the farmhouse location from WorldGenerator.gd layout.
const DEFAULT_CENTER_X: int = 40
const DEFAULT_CENTER_Y: int = 30
var world_center: Vector2i = Vector2i(DEFAULT_CENTER_X, DEFAULT_CENTER_Y)

## Tile size
const TILE_SIZE: int = 16

## Chunk size must match ChunkManager
const CHUNK_SIZE: int = 32

## Island radius in tiles - land area fades to ocean beyond this distance
const ISLAND_RADIUS: float = 60.0

## Transition zone width where land blends into ocean
const ISLAND_SHORE_WIDTH: float = 15.0

## Distance in tiles to sample neighbors for adjacency rule checks
const ADJACENCY_CHECK_DISTANCE: int = 4

## Probability (0.0-1.0) that a chunk contains a structure
const STRUCTURE_SPAWN_CHANCE: float = 0.15

## Structure placement tracking to avoid duplicates
var placed_structures: Dictionary = {}

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	# Default seed from calendar-based daily seed, or random
	if world_seed == 0:
		world_seed = randi()
	initialize(world_seed)


func initialize(seed_value: int) -> void:
	## Initializes or re-initializes the generator with a new seed.
	world_seed = seed_value
	noise_gen = NoiseGeneratorScript.new(world_seed)
	_rng.seed = world_seed
	placed_structures.clear()


func generate_chunk(chunk_pos: Vector2i) -> Dictionary:
	## Generates all tile data for a single chunk.
	## Returns a dictionary with ground, biome_map, objects, and structures.
	##
	## Layered generation order (Necesse approach):
	##   1. Base terrain from height noise
	##   2. Biome assignment from height + moisture + temperature + distance
	##   3. Water features (rivers, lakes)
	##   4. Cave carving
	##   5. Vegetation and resource objects
	##   6. Structure / point-of-interest placement

	var origin := Vector2i(chunk_pos.x * CHUNK_SIZE, chunk_pos.y * CHUNK_SIZE)

	# Layer 1 & 2: Ground terrain and biome assignment
	var ground_tiles: Dictionary = {}
	var biome_map: Dictionary = {}
	var water_tiles: Dictionary = {}
	var cave_tiles: Dictionary = {}
	var object_tiles: Dictionary = {}

	for lx in range(CHUNK_SIZE):
		for ly in range(CHUNK_SIZE):
			var wx := origin.x + lx
			var wy := origin.y + ly
			var local := Vector2i(lx, ly)
			var world := Vector2i(wx, wy)

			# Noise values
			var height: float = noise_gen.get_height(wx, wy)
			var moisture: float = noise_gen.get_moisture(wx, wy)
			var temperature: float = noise_gen.get_temperature(wx, wy)
			var dist := _distance_from_center(wx, wy)

			# Apply island falloff - lower height at edges to create ocean
			var falloff := _island_falloff(dist)
			height = height * falloff

			# Determine biome
			var biome_id: String = _determine_biome_with_adjacency(
				wx, wy, height, moisture, temperature, dist)
			biome_map[local] = biome_id

			# Layer 1: Base ground tile
			ground_tiles[local] = _select_ground_tile(biome_id, wx, wy, height)

			# Layer 3: Water features
			if _is_water_tile(wx, wy, height, moisture):
				water_tiles[local] = "water"

			# Layer 4: Cave carving (underground areas at low height)
			if noise_gen.is_cave(wx, wy) and height < 0.3:
				cave_tiles[local] = "cave"

			# Layer 5: Vegetation and resources
			var obj := _place_vegetation(biome_id, wx, wy)
			if not obj.is_empty():
				object_tiles[local] = obj

	# Layer 6: Structure placement
	var structures := _place_structures(chunk_pos, origin, biome_map)

	return {
		"chunk_pos": chunk_pos,
		"origin": origin,
		"ground_tiles": ground_tiles,
		"biome_map": biome_map,
		"water_tiles": water_tiles,
		"cave_tiles": cave_tiles,
		"object_tiles": object_tiles,
		"structures": structures
	}


func _distance_from_center(wx: int, wy: int) -> float:
	## Calculates distance from world center in tiles.
	var dx := float(wx - world_center.x)
	var dy := float(wy - world_center.y)
	return sqrt(dx * dx + dy * dy)


func _island_falloff(dist: float) -> float:
	## Returns a multiplier [0.0, 1.0] that shapes terrain into an island.
	## 1.0 at center, smoothly drops to 0.0 at and beyond ISLAND_RADIUS.
	if dist <= ISLAND_RADIUS - ISLAND_SHORE_WIDTH:
		return 1.0
	if dist >= ISLAND_RADIUS:
		return 0.0
	# Smooth hermite interpolation in the shore transition zone
	var t := (dist - (ISLAND_RADIUS - ISLAND_SHORE_WIDTH)) / ISLAND_SHORE_WIDTH
	return 1.0 - t * t * (3.0 - 2.0 * t)


func _determine_biome_with_adjacency(wx: int, wy: int, height: float,
		moisture: float, temperature: float, dist: float) -> String:
	## Determines biome using noise values + distance, then checks adjacency
	## rules against neighbors to smooth transitions (Necesse-style).
	if not has_node("/root/BiomeSystem"):
		return "meadow"
	var biome_sys: Node = get_node("/root/BiomeSystem")
	var biome_id: String = biome_sys.determine_biome(height, moisture, temperature, dist)

	# Check adjacency: sample a few neighbors and if incompatible, try fallback
	var neighbor_offsets := [
		Vector2i(-ADJACENCY_CHECK_DISTANCE, 0),
		Vector2i(ADJACENCY_CHECK_DISTANCE, 0),
		Vector2i(0, -ADJACENCY_CHECK_DISTANCE),
		Vector2i(0, ADJACENCY_CHECK_DISTANCE)]
	for offset: Vector2i in neighbor_offsets:
		var nx := wx + offset.x
		var ny := wy + offset.y
		var n_height: float = noise_gen.get_height(nx, ny)
		var n_moisture: float = noise_gen.get_moisture(nx, ny)
		var n_temp: float = noise_gen.get_temperature(nx, ny)
		var n_dist := _distance_from_center(nx, ny)
		var neighbor_biome: String = biome_sys.determine_biome(
			n_height, n_moisture, n_temp, n_dist)

		if neighbor_biome != biome_id and not biome_sys.can_be_adjacent(biome_id, neighbor_biome):
			# Use a transition: pick from allowed neighbors of the neighbor
			var allowed: Array = biome_sys.get_allowed_neighbors(neighbor_biome)
			if not allowed.is_empty():
				# Pick the allowed neighbor with the best noise score
				var best: String = allowed[0]
				var best_score: float = -1.0
				for candidate: String in allowed:
					var b: Dictionary = biome_sys.get_biome(candidate)
					if not b.is_empty():
						var s: float = biome_sys._score_biome_match(b, height, moisture, temperature)
						if s > best_score:
							best_score = s
							best = candidate
				biome_id = best
				break

	return biome_id


func _select_ground_tile(biome_id: String, wx: int, wy: int, _height: float) -> String:
	## Selects a ground tile type for the given biome and position.
	## Uses the detail noise to add variation within a biome.
	if not has_node("/root/BiomeSystem"):
		return "grass"
	var biome_sys: Node = get_node("/root/BiomeSystem")
	var biome: Dictionary = biome_sys.get_biome(biome_id)
	var tiles: Array = biome.get("ground_tiles", ["grass"])
	if tiles.is_empty():
		return "grass"
	var idx: int = noise_gen.tile_hash(wx, wy) % tiles.size()
	return tiles[idx]


func _is_water_tile(wx: int, wy: int, height: float, moisture: float) -> bool:
	## Determines if a tile should be water.
	## Low height + high moisture = lake.
	## River value near zero = river channel.
	## Tiles beyond the island radius are always ocean.
	var dist := _distance_from_center(wx, wy)
	if dist >= ISLAND_RADIUS:
		return true
	if height < 0.18 and moisture > 0.55:
		return true
	var river: float = noise_gen.get_river_value(wx, wy)
	if river < 0.03 and height < 0.45:
		return true
	return false


func _place_vegetation(biome_id: String, wx: int, wy: int) -> String:
	## Determines if vegetation or a resource object should be placed here.
	## Returns the object type string, or empty string for nothing.
	if not has_node("/root/BiomeSystem"):
		return ""
	var biome_sys: Node = get_node("/root/BiomeSystem")
	var biome: Dictionary = biome_sys.get_biome(biome_id)
	var detail: float = noise_gen.get_detail(wx, wy)
	var hash_val: int = noise_gen.tile_hash(wx, wy)

	# Trees
	var tree_density: float = biome.get("tree_density", 0.0)
	if tree_density > 0.0 and detail < tree_density:
		return "tree"

	# Vegetation
	var veg_density: float = biome.get("vegetation_density", 0.0)
	var vegetation: Array = biome.get("vegetation", [])
	if veg_density > 0.0 and not vegetation.is_empty():
		if detail > (1.0 - veg_density) and detail < 1.0:
			return vegetation[hash_val % vegetation.size()]

	# Resources
	var res_density: float = biome.get("resource_density", 0.0)
	var resources: Array = biome.get("resources", [])
	if res_density > 0.0 and not resources.is_empty():
		# Use a separate noise band for resources to avoid overlapping vegetation
		var res_noise: float = noise_gen.get_detail(wx + 1000, wy + 1000)
		if res_noise < res_density:
			return resources[hash_val % resources.size()]

	return ""


func _place_structures(chunk_pos: Vector2i, origin: Vector2i,
		biome_map: Dictionary) -> Array:
	## Places points of interest / structures within this chunk.
	## Uses a seeded RNG per chunk for deterministic placement.
	## Only one structure per chunk to avoid clutter.
	if not has_node("/root/BiomeSystem"):
		return []
	var biome_sys: Node = get_node("/root/BiomeSystem")

	# Seed RNG for this specific chunk
	var chunk_seed := world_seed + chunk_pos.x * 73856093 + chunk_pos.y * 19349663
	_rng.seed = chunk_seed

	# Only place a structure with configured probability per chunk
	if _rng.randf() > STRUCTURE_SPAWN_CHANCE:
		return []

	# Find the dominant biome in this chunk
	var biome_counts: Dictionary = {}
	for local_pos: Vector2i in biome_map:
		var b: String = biome_map[local_pos]
		biome_counts[b] = biome_counts.get(b, 0) + 1
	var dominant_biome: String = ""
	var max_count: int = 0
	for b: String in biome_counts:
		if biome_counts[b] > max_count:
			max_count = biome_counts[b]
			dominant_biome = b

	if dominant_biome.is_empty():
		return []

	var possible: Array = biome_sys.get_structures_for_biome(dominant_biome)
	if possible.is_empty():
		return []

	# Pick a random structure type and position within the chunk
	var struct_type: String = possible[_rng.randi_range(0, possible.size() - 1)]
	var sx := _rng.randi_range(4, CHUNK_SIZE - 5)
	var sy := _rng.randi_range(4, CHUNK_SIZE - 5)

	var struct_key := "%d_%d" % [chunk_pos.x, chunk_pos.y]
	if placed_structures.has(struct_key):
		return []
	placed_structures[struct_key] = true

	return [{
		"type": struct_type,
		"tile_pos": Vector2i(origin.x + sx, origin.y + sy),
		"chunk_pos": chunk_pos,
		"biome": dominant_biome
	}]


func get_world_info() -> Dictionary:
	## Returns a summary of the world generation configuration.
	return {
		"seed": world_seed,
		"center": world_center,
		"chunk_size": CHUNK_SIZE,
		"tile_size": TILE_SIZE,
		"structures_placed": placed_structures.size()
	}


func get_save_data() -> Dictionary:
	return {
		"world_seed": world_seed,
		"center_x": world_center.x,
		"center_y": world_center.y,
		"placed_structures": placed_structures.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("world_seed"):
		initialize(data.world_seed)
	if data.has("center_x") and data.has("center_y"):
		world_center = Vector2i(data.center_x, data.center_y)
	if data.has("placed_structures"):
		placed_structures = data.placed_structures.duplicate()
