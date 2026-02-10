extends Node2D
## Farm - Main farm scene managing the player's farm area.
## Handles world generation and multiplayer player spawning.
## Wires the OverworldGenerator and ChunkManager to stream procedural
## island terrain around the player as they explore.

@onready var crop_manager = $CropManager
@onready var player_spawner = $Players
@onready var ground_layer = $GroundLayer
@onready var paths_layer = $PathsLayer
@onready var plantable_layer = $PlantableArea
@onready var objects_layer = $ObjectsLayer

const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")
const DEFAULT_SPAWN := Vector2(224, 192)

## Maps ground type strings from the generator to Overworld.png atlas coords.
const _GROUND_ATLAS_MAP: Dictionary = {
	"grass": Vector2i(0, 0),
	"grass_light": Vector2i(1, 4),
	"dirt": Vector2i(7, 1),
	"forest_floor": Vector2i(0, 3),
	"sand": Vector2i(9, 1),
	"stone": Vector2i(12, 3),
	"marsh": Vector2i(2, 3),
	"snow": Vector2i(0, 5),
	"cave_floor": Vector2i(8, 1),
}

var world_generator: Node
var _spawn_positions: Array[Vector2] = []

## TileMapLayer used for procedurally generated overworld chunks
var overworld_layer: TileMapLayer = null

## Tileset shared by both static farm and overworld layers
var _tileset: TileSet = null


func _ready():
	_setup_farm()
	_setup_overworld()
	EventBus.day_ended.connect(_on_day_ended)

	if multiplayer.has_multiplayer_peer():
		_setup_multiplayer()
	else:
		_spawn_local_player()


func _setup_multiplayer():
	NetworkManager.player_disconnected.connect(_on_network_player_disconnected)

	if multiplayer.is_server():
		for peer_id in NetworkManager.players:
			_spawn_player(peer_id)
		multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)


func _spawn_local_player():
	var player = PLAYER_SCENE.instantiate()
	player.name = "Player"
	player.position = _spawn_positions[0] if _spawn_positions.size() > 0 else DEFAULT_SPAWN
	player_spawner.add_child(player)


func _spawn_player(peer_id: int):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	var index = clampi(NetworkManager.players.keys().find(peer_id), 0, _spawn_positions.size() - 1)
	player.position = _spawn_positions[index] if _spawn_positions.size() > 0 else DEFAULT_SPAWN

	player_spawner.add_child(player)


func _on_multiplayer_peer_connected(peer_id: int):
	await get_tree().create_timer(0.1).timeout
	_spawn_player(peer_id)


func _on_network_player_disconnected(peer_id: int):
	var player_node = player_spawner.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()


func _setup_farm():
	## Generate the farm world using WorldGenerator
	world_generator = Node.new()
	world_generator.set_script(load("res://scripts/systems/WorldGenerator.gd"))
	add_child(world_generator)

	_tileset = _create_tileset()
	world_generator.generate_farm(ground_layer, paths_layer, plantable_layer, objects_layer, _tileset)

	# Set spawn positions based on world generator
	var base_spawn: Vector2 = world_generator.get_spawn_position()
	_spawn_positions = [
		base_spawn,
		base_spawn + Vector2(24, 0),
		base_spawn + Vector2(0, 24),
		base_spawn + Vector2(24, 24),
	]


func _setup_overworld():
	## Initialize the OverworldGenerator and ChunkManager autoloads and create
	## a dedicated TileMapLayer for procedural island terrain rendered below the
	## static farm layers.
	overworld_layer = TileMapLayer.new()
	overworld_layer.name = "OverworldLayer"
	overworld_layer.y_sort_enabled = true
	if _tileset:
		overworld_layer.tile_set = _tileset
	# Insert below the ground layer so static farm tiles draw on top
	add_child(overworld_layer)
	move_child(overworld_layer, 0)

	# Connect the autoloaded generator to the chunk manager
	if has_node("/root/OverworldGenerator") and has_node("/root/ChunkManager"):
		var owg: Node = get_node("/root/OverworldGenerator")
		var cm: Node = get_node("/root/ChunkManager")
		cm.world_generator = owg
		cm.chunk_loaded.connect(_on_chunk_loaded)
		cm.chunk_unloaded.connect(_on_chunk_unloaded)

		# Trigger initial chunk load around the spawn point
		var spawn := _spawn_positions[0] if _spawn_positions.size() > 0 else DEFAULT_SPAWN
		cm.update_player_position(spawn)


func _process(_delta: float) -> void:
	## Feed the local player position into ChunkManager each frame so nearby
	## chunks are streamed in as the player moves.
	if not has_node("/root/ChunkManager"):
		return
	var cm: Node = get_node("/root/ChunkManager")
	var player := _get_local_player()
	if player:
		cm.update_player_position(player.global_position)


func _get_local_player() -> Node:
	## Returns the local player node, or null if not spawned yet.
	for child in player_spawner.get_children():
		if child is CharacterBody2D:
			if not multiplayer.has_multiplayer_peer() or child.is_multiplayer_authority():
				return child
	return null


func _on_chunk_loaded(chunk_pos: Vector2i) -> void:
	## Render a newly generated chunk onto the overworld TileMapLayer.
	if not has_node("/root/ChunkManager") or overworld_layer == null:
		return
	var cm: Node = get_node("/root/ChunkManager")
	var chunk: Dictionary = cm.get_chunk_data(chunk_pos)
	if chunk.is_empty():
		return

	var origin: Vector2i = chunk.get("origin", Vector2i.ZERO)
	var ground_tiles: Dictionary = chunk.get("ground_tiles", {})
	var water_tiles: Dictionary = chunk.get("water_tiles", {})

	# Use Overworld source (0) with known atlas coordinates.
	var water_atlas := Vector2i(19, 0)

	for local_pos: Vector2i in ground_tiles:
		var world_tile := Vector2i(origin.x + local_pos.x, origin.y + local_pos.y)
		if water_tiles.has(local_pos):
			overworld_layer.set_cell(world_tile, 0, water_atlas)
		else:
			var ground_type: String = ground_tiles[local_pos]
			var atlas := _ground_type_to_atlas(ground_type)
			overworld_layer.set_cell(world_tile, 0, atlas)

	# Fill any remaining water tiles not in ground_tiles
	for local_pos: Vector2i in water_tiles:
		if not ground_tiles.has(local_pos):
			var world_tile := Vector2i(origin.x + local_pos.x, origin.y + local_pos.y)
			overworld_layer.set_cell(world_tile, 0, water_atlas)


func _on_chunk_unloaded(chunk_pos: Vector2i) -> void:
	## Erase tiles for an unloaded chunk to free rendering resources.
	if overworld_layer == null:
		return
	var chunk_size := 32
	var origin := Vector2i(chunk_pos.x * chunk_size, chunk_pos.y * chunk_size)
	for lx in range(chunk_size):
		for ly in range(chunk_size):
			overworld_layer.erase_cell(Vector2i(origin.x + lx, origin.y + ly))


func _ground_type_to_atlas(ground_type: String) -> Vector2i:
	## Maps a ground type string to an Overworld.png atlas coordinate.
	return _GROUND_ATLAS_MAP.get(ground_type, Vector2i(0, 0))


func _create_tileset() -> TileSet:
	## Build a TileSet resource from the Overworld tileset image
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)

	# Add physics layer for world collisions
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)  # World layer

	# Source 0: Overworld tileset
	var overworld_source := TileSetAtlasSource.new()
	var overworld_texture := load("res://gfx/Overworld.png") as Texture2D
	if overworld_texture:
		overworld_source.texture = overworld_texture
		overworld_source.texture_region_size = Vector2i(16, 16)
		tileset.add_source(overworld_source, 0)
		# Create atlas tiles for all cells in the texture
		var tex_size := overworld_texture.get_size()
		var cols := int(tex_size.x) / 16
		var rows := int(tex_size.y) / 16
		for x in range(cols):
			for y in range(rows):
				var atlas_coords := Vector2i(x, y)
				overworld_source.create_tile(atlas_coords)

	# Source 1: Objects tileset
	var objects_source := TileSetAtlasSource.new()
	var objects_texture := load("res://gfx/objects.png") as Texture2D
	if objects_texture:
		objects_source.texture = objects_texture
		objects_source.texture_region_size = Vector2i(16, 16)
		tileset.add_source(objects_source, 1)
		var tex_size := objects_texture.get_size()
		var cols := int(tex_size.x) / 16
		var rows := int(tex_size.y) / 16
		for x in range(cols):
			for y in range(rows):
				var atlas_coords := Vector2i(x, y)
				objects_source.create_tile(atlas_coords)

	return tileset


func get_tile_at_position(world_pos: Vector2) -> Vector2i:
	if plantable_layer:
		return plantable_layer.local_to_map(plantable_layer.to_local(world_pos))
	return Vector2i.ZERO


func is_plantable(tile_pos: Vector2i) -> bool:
	if plantable_layer:
		var source_id: int = plantable_layer.get_cell_source_id(tile_pos)
		return source_id != -1
	return false


func till_soil(tile_pos: Vector2i) -> bool:
	## Convert a ground tile into plantable farmland
	if not plantable_layer:
		return false
	if is_plantable(tile_pos):
		return false
	# Only allow tilling within farm boundaries
	if tile_pos.x < 6 or tile_pos.x >= 74 or tile_pos.y < 6 or tile_pos.y >= 54:
		return false
	plantable_layer.set_cell(tile_pos, 0, Vector2i(34, 17))
	return true


func _on_day_ended():
	crop_manager.advance_all_crops()
