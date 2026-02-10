extends Node
## ChunkManager - Manages chunk-based world streaming for on-demand generation.
## Inspired by Necesse's infinite seamless world that only generates map areas
## as the player explores, and Core Keeper's progressive terrain reveal.
##
## The world is divided into square chunks. When the player moves, nearby chunks
## are generated and distant chunks are unloaded to conserve memory.

## Chunk size in tiles (each chunk is CHUNK_SIZE x CHUNK_SIZE tiles)
const CHUNK_SIZE: int = 32

## How many chunks around the player to keep loaded
const LOAD_RADIUS: int = 3

## How many chunks beyond load radius before unloading
const UNLOAD_RADIUS: int = 5

## Currently loaded chunks: key = Vector2i(chunk_x, chunk_y), value = chunk data
var loaded_chunks: Dictionary = {}

## Set of chunk coordinates that have been generated at least once (persistent)
var generated_chunks: Dictionary = {}

## The player's current chunk position
var current_player_chunk: Vector2i = Vector2i.ZERO

## Reference to the overworld generator (set externally)
var world_generator: Node = null

## Tile size in pixels
const TILE_SIZE: int = 16

signal chunk_loaded(chunk_pos: Vector2i)
signal chunk_unloaded(chunk_pos: Vector2i)
signal chunks_updated


func _ready() -> void:
	pass


func update_player_position(world_pos: Vector2) -> void:
	## Call when the player moves. Determines if new chunks need loading.
	var new_chunk := world_to_chunk(world_pos)
	if new_chunk != current_player_chunk:
		current_player_chunk = new_chunk
		_update_loaded_chunks()


func world_to_chunk(world_pos: Vector2) -> Vector2i:
	## Converts a world-space position to the chunk coordinate it belongs to.
	var tile_x := int(world_pos.x) / TILE_SIZE
	var tile_y := int(world_pos.y) / TILE_SIZE
	# Handle negative coordinates correctly
	if world_pos.x < 0:
		tile_x -= 1
	if world_pos.y < 0:
		tile_y -= 1
	return Vector2i(tile_x / CHUNK_SIZE, tile_y / CHUNK_SIZE)


func chunk_to_world_origin(chunk_pos: Vector2i) -> Vector2i:
	## Returns the top-left tile coordinate of the given chunk.
	return Vector2i(chunk_pos.x * CHUNK_SIZE, chunk_pos.y * CHUNK_SIZE)


func is_chunk_loaded(chunk_pos: Vector2i) -> bool:
	return loaded_chunks.has(chunk_pos)


func get_chunk_data(chunk_pos: Vector2i) -> Dictionary:
	## Returns the tile data for a loaded chunk, or empty if not loaded.
	return loaded_chunks.get(chunk_pos, {})


func get_biome_at(world_pos: Vector2) -> String:
	## Returns the biome ID at the given world position.
	var chunk_pos := world_to_chunk(world_pos)
	var chunk := loaded_chunks.get(chunk_pos, {})
	if chunk.is_empty():
		return ""
	var origin := chunk_to_world_origin(chunk_pos)
	var tile_x := int(world_pos.x) / TILE_SIZE
	var tile_y := int(world_pos.y) / TILE_SIZE
	if world_pos.x < 0:
		tile_x -= 1
	if world_pos.y < 0:
		tile_y -= 1
	var local := Vector2i(tile_x - origin.x, tile_y - origin.y)
	var biome_map: Dictionary = chunk.get("biome_map", {})
	return biome_map.get(local, "")


func force_load_chunk(chunk_pos: Vector2i) -> void:
	## Forces a single chunk to be generated and loaded immediately.
	if not loaded_chunks.has(chunk_pos):
		_load_chunk(chunk_pos)


func _update_loaded_chunks() -> void:
	## Loads chunks within LOAD_RADIUS and unloads chunks beyond UNLOAD_RADIUS.

	# Determine which chunks should be loaded
	var desired: Array[Vector2i] = []
	for cx in range(current_player_chunk.x - LOAD_RADIUS,
			current_player_chunk.x + LOAD_RADIUS + 1):
		for cy in range(current_player_chunk.y - LOAD_RADIUS,
				current_player_chunk.y + LOAD_RADIUS + 1):
			desired.append(Vector2i(cx, cy))

	# Load new chunks
	for chunk_pos: Vector2i in desired:
		if not loaded_chunks.has(chunk_pos):
			_load_chunk(chunk_pos)

	# Unload distant chunks
	var to_unload: Array[Vector2i] = []
	for chunk_pos: Vector2i in loaded_chunks.keys():
		var dist := _chunk_distance(chunk_pos, current_player_chunk)
		if dist > UNLOAD_RADIUS:
			to_unload.append(chunk_pos)

	for chunk_pos: Vector2i in to_unload:
		_unload_chunk(chunk_pos)

	if not desired.is_empty() or not to_unload.is_empty():
		chunks_updated.emit()


func _load_chunk(chunk_pos: Vector2i) -> void:
	## Generates (or re-loads) chunk data and stores it.
	if world_generator and world_generator.has_method("generate_chunk"):
		var chunk_data: Dictionary = world_generator.generate_chunk(chunk_pos)
		loaded_chunks[chunk_pos] = chunk_data
		generated_chunks[chunk_pos] = true
		chunk_loaded.emit(chunk_pos)


func _unload_chunk(chunk_pos: Vector2i) -> void:
	## Removes a chunk from the active set to free memory.
	## The chunk remains in generated_chunks so it can be restored.
	if loaded_chunks.has(chunk_pos):
		loaded_chunks.erase(chunk_pos)
		chunk_unloaded.emit(chunk_pos)


func _chunk_distance(a: Vector2i, b: Vector2i) -> int:
	## Chebyshev distance between two chunk positions.
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func get_loaded_chunk_count() -> int:
	return loaded_chunks.size()


func get_generated_chunk_count() -> int:
	return generated_chunks.size()


func get_save_data() -> Dictionary:
	## Returns data needed to persist world state.
	## We store which chunks have been generated and their biome assignments.
	var chunks_data: Dictionary = {}
	for chunk_pos: Vector2i in generated_chunks:
		var key := "%d,%d" % [chunk_pos.x, chunk_pos.y]
		var chunk: Dictionary = loaded_chunks.get(chunk_pos, {})
		if not chunk.is_empty():
			# Store biome map as serializable data
			var biome_data: Dictionary = {}
			var biome_map: Dictionary = chunk.get("biome_map", {})
			for tile_pos: Vector2i in biome_map:
				var tile_key := "%d,%d" % [tile_pos.x, tile_pos.y]
				biome_data[tile_key] = biome_map[tile_pos]
			chunks_data[key] = {"biome_map": biome_data}
	return {
		"player_chunk": {"x": current_player_chunk.x, "y": current_player_chunk.y},
		"generated_chunks_keys": _serialize_chunk_keys(),
		"chunks_data": chunks_data
	}


func load_save_data(data: Dictionary) -> void:
	## Restores world state from saved data.
	if data.has("player_chunk"):
		current_player_chunk = Vector2i(
			data.player_chunk.get("x", 0),
			data.player_chunk.get("y", 0)
		)
	if data.has("generated_chunks_keys"):
		_deserialize_chunk_keys(data.generated_chunks_keys)


func _serialize_chunk_keys() -> Array:
	var keys: Array = []
	for chunk_pos: Vector2i in generated_chunks:
		keys.append({"x": chunk_pos.x, "y": chunk_pos.y})
	return keys


func _deserialize_chunk_keys(keys: Array) -> void:
	generated_chunks.clear()
	for entry in keys:
		var pos := Vector2i(entry.get("x", 0), entry.get("y", 0))
		generated_chunks[pos] = true
