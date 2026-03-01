extends Node2D
## DungeonRoom - Base class for all dungeon room types.
## Handles doors, clear conditions, and room-type specific logic.

signal room_cleared(room_id: String)
signal door_entered(target_room_id: String)

enum RoomType { ENTRANCE, COMBAT, PUZZLE, TREASURE, KEY, BOSS, CORRIDOR, TRAP }

@export var room_id: String = ""
@export var room_type: RoomType = RoomType.CORRIDOR
@export var difficulty: int = 1
@export var puzzle_type: String = ""

## Door connection targets keyed by direction name
@export var door_connections: Dictionary = {}

var is_cleared: bool = false
var enemies_remaining: int = 0
var puzzle_solved: bool = false


func _ready() -> void:
	_generate_tilemap()
	_setup_room()


func _generate_tilemap() -> void:
	var tilemap := get_node_or_null("TileMap") as TileMap
	if not tilemap:
		return
	var gen = load(
		"res://scripts/dungeon/DungeonRoomGenerator.gd")
	var doors := {}
	for dir_name: String in door_connections:
		doors[dir_name] = true
	var seed_val := room_id.hash() if room_id != "" else 0
	gen.generate_room(
		tilemap, room_type, doors, seed_val)


func _setup_room() -> void:
	match room_type:
		RoomType.COMBAT:
			_setup_combat_room()
		RoomType.PUZZLE:
			_setup_puzzle_room()
		RoomType.TREASURE:
			_setup_treasure_room()
		RoomType.BOSS:
			_setup_boss_room()
		_:
			_mark_cleared()


func _setup_combat_room() -> void:
	enemies_remaining = difficulty + 1


func _setup_puzzle_room() -> void:
	puzzle_solved = false


func _setup_treasure_room() -> void:
	_mark_cleared()


func _setup_boss_room() -> void:
	enemies_remaining = 1


func on_enemy_defeated() -> void:
	enemies_remaining = maxi(enemies_remaining - 1, 0)
	if enemies_remaining <= 0:
		_mark_cleared()


func on_puzzle_solved() -> void:
	puzzle_solved = true
	_mark_cleared()


func enter_door(direction: String) -> void:
	var target: String = door_connections.get(direction, "")
	if target != "":
		door_entered.emit(target)


func _mark_cleared() -> void:
	if is_cleared:
		return
	is_cleared = true
	room_cleared.emit(room_id)
	EventBus.dungeon_room_cleared.emit(room_id)


func get_save_data() -> Dictionary:
	return {
		"room_id": room_id,
		"is_cleared": is_cleared,
		"enemies_remaining": enemies_remaining,
		"puzzle_solved": puzzle_solved
	}


func load_save_data(data: Dictionary) -> void:
	is_cleared = data.get("is_cleared", false)
	enemies_remaining = data.get("enemies_remaining", 0)
	puzzle_solved = data.get("puzzle_solved", false)
