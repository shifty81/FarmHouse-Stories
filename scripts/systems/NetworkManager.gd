extends Node
## NetworkManager - Manages multiplayer connections, hosting, and joining.
## Autoloaded as a global singleton.

const DEFAULT_PORT: int = 9999
const MAX_PLAYERS: int = 4

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal connection_succeeded
signal connection_failed
signal server_started

## Tracks connected player info: { peer_id: { "name": String, "position": Vector2 } }
var players: Dictionary = {}
var local_player_name: String = "Farmer"


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func host_game(port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYERS)
	if error != OK:
		print("Failed to create server: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	players[1] = {"name": local_player_name}
	print("Server started on port ", port)
	server_started.emit()
	return OK


func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("Failed to create client: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	print("Connecting to ", address, ":", port)
	return OK


func disconnect_game():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	players.clear()


func is_server() -> bool:
	return multiplayer.multiplayer_peer != null and multiplayer.is_server()


func is_online() -> bool:
	return multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _on_peer_connected(id: int):
	print("Player connected: ", id)
	# Send our info to the new player
	_register_player.rpc_id(id, local_player_name)


func _on_peer_disconnected(id: int):
	print("Player disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_to_server():
	print("Connected to server!")
	var my_id = multiplayer.get_unique_id()
	players[my_id] = {"name": local_player_name}
	_register_player.rpc(local_player_name)
	connection_succeeded.emit()


func _on_connection_failed():
	print("Connection failed!")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	print("Server disconnected!")
	multiplayer.multiplayer_peer = null
	players.clear()


@rpc("any_peer", "reliable")
func _register_player(player_name: String):
	var sender_id = multiplayer.get_remote_sender_id()
	players[sender_id] = {"name": player_name}
	player_connected.emit(sender_id)
