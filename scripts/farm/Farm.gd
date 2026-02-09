extends Node2D
## Farm - Main farm scene managing the player's farm area.
## Handles world generation and multiplayer player spawning.

@onready var crop_manager = $CropManager
@onready var player_spawner = $Players
@onready var ground_layer = $GroundLayer
@onready var paths_layer = $PathsLayer
@onready var plantable_layer = $PlantableArea
@onready var objects_layer = $ObjectsLayer

const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")
const DEFAULT_SPAWN := Vector2(328, 248)

var world_generator: Node
var _spawn_positions: Array[Vector2] = []


func _ready():
	_setup_farm()
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

	var tileset := _create_tileset()
	world_generator.generate_farm(ground_layer, paths_layer, plantable_layer, objects_layer, tileset)

	# Set spawn positions based on world generator
	var base_spawn: Vector2 = world_generator.get_spawn_position()
	_spawn_positions = [
		base_spawn,
		base_spawn + Vector2(24, 0),
		base_spawn + Vector2(0, 24),
		base_spawn + Vector2(24, 24),
	]


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


func _on_day_ended():
	crop_manager.advance_all_crops()
