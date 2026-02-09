extends Node2D
## Farm - Main farm scene managing the player's farm area.
## Handles multiplayer player spawning when connected.

@onready var crop_manager = $CropManager
@onready var player_spawner = $Players

const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")

var _spawn_positions: Array[Vector2] = [
	Vector2(640, 360),
	Vector2(700, 360),
	Vector2(640, 420),
	Vector2(700, 420),
]


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
		# Server spawns all existing players
		for peer_id in NetworkManager.players:
			_spawn_player(peer_id)
		# Listen for new connections
		multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)


func _spawn_local_player():
	var player = PLAYER_SCENE.instantiate()
	player.name = "Player"
	player.position = _spawn_positions[0]
	player_spawner.add_child(player)


func _spawn_player(peer_id: int):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	var index = clampi(NetworkManager.players.keys().find(peer_id), 0, _spawn_positions.size() - 1)
	player.position = _spawn_positions[index]

	player_spawner.add_child(player)


func _on_multiplayer_peer_connected(peer_id: int):
	# Small delay to allow registration
	await get_tree().create_timer(0.1).timeout
	_spawn_player(peer_id)


func _on_network_player_disconnected(peer_id: int):
	var player_node = player_spawner.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()


func _setup_farm():
	pass


func get_tile_at_position(world_pos: Vector2) -> Vector2i:
	var plantable_tilemap = get_node_or_null("PlantableArea")
	if plantable_tilemap:
		return plantable_tilemap.local_to_map(plantable_tilemap.to_local(world_pos))
	return Vector2i.ZERO


func is_plantable(tile_pos: Vector2i) -> bool:
	var plantable_tilemap = get_node_or_null("PlantableArea")
	if plantable_tilemap:
		var tile_data = plantable_tilemap.get_cell_tile_data(0, tile_pos)
		return tile_data != null
	return false


func _on_day_ended():
	crop_manager.advance_all_crops()
