extends Control
## MultiplayerLobby - UI for hosting or joining a multiplayer game.

@onready var host_button = $VBoxContainer/HostButton
@onready var join_button = $VBoxContainer/JoinButton
@onready var disconnect_button = $VBoxContainer/DisconnectButton
@onready var address_input = $VBoxContainer/AddressInput
@onready var port_input = $VBoxContainer/PortInput
@onready var name_input = $VBoxContainer/NameInput
@onready var status_label = $VBoxContainer/StatusLabel
@onready var player_list = $VBoxContainer/PlayerList
@onready var start_button = $VBoxContainer/StartButton
@onready var singleplayer_button = $VBoxContainer/SingleplayerButton


func _ready():
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.server_started.connect(_on_server_started)

	disconnect_button.visible = false
	start_button.visible = false
	_update_player_list()


func _on_host_pressed():
	var port = int(port_input.text) if port_input.text.is_valid_int() else NetworkManager.DEFAULT_PORT
	NetworkManager.local_player_name = name_input.text if name_input.text != "" else "Host"

	var error = NetworkManager.host_game(port)
	if error == OK:
		status_label.text = "Hosting on port %d..." % port
		host_button.disabled = true
		join_button.disabled = true
		singleplayer_button.disabled = true
		disconnect_button.visible = true
		start_button.visible = true
	else:
		status_label.text = "Failed to host: error %d" % error


func _on_join_pressed():
	var address = address_input.text if address_input.text != "" else "127.0.0.1"
	var port = int(port_input.text) if port_input.text.is_valid_int() else NetworkManager.DEFAULT_PORT
	NetworkManager.local_player_name = name_input.text if name_input.text != "" else "Guest"

	var error = NetworkManager.join_game(address, port)
	if error == OK:
		status_label.text = "Connecting to %s:%d..." % [address, port]
		host_button.disabled = true
		join_button.disabled = true
		singleplayer_button.disabled = true
		disconnect_button.visible = true
	else:
		status_label.text = "Failed to join: error %d" % error


func _on_disconnect_pressed():
	NetworkManager.disconnect_game()
	status_label.text = "Disconnected."
	host_button.disabled = false
	join_button.disabled = false
	singleplayer_button.disabled = false
	disconnect_button.visible = false
	start_button.visible = false
	_update_player_list()


func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/farm/Farm.tscn")


func _on_start_pressed():
	if NetworkManager.is_server():
		_start_game.rpc()


@rpc("authority", "call_local", "reliable")
func _start_game():
	get_tree().change_scene_to_file("res://scenes/farm/Farm.tscn")


func _on_server_started():
	status_label.text = "Server started! Waiting for players..."
	_update_player_list()


func _on_connection_succeeded():
	status_label.text = "Connected!"
	_update_player_list()


func _on_connection_failed():
	status_label.text = "Connection failed!"
	host_button.disabled = false
	join_button.disabled = false
	singleplayer_button.disabled = false
	disconnect_button.visible = false


func _on_player_connected(_id: int):
	_update_player_list()


func _on_player_disconnected(_id: int):
	_update_player_list()


func _update_player_list():
	if not player_list:
		return
	player_list.clear()
	for id in NetworkManager.players:
		var info = NetworkManager.players[id]
		var suffix = " (Host)" if id == 1 else ""
		player_list.add_item("%s%s" % [info.get("name", "Unknown"), suffix])
