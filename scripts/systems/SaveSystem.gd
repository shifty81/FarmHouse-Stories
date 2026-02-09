extends Node
## SaveSystem - Handles saving and loading game state to/from disk.

const SAVE_FILE: String = "user://farmhouse_save.json"

## Cached autoload references for performance
var _npc_db: Node
var _gear_system: Node
var _dungeon_system: Node
var _rift_system: Node
var _event_system: Node
var _inventory: Node
var _dialogue: Node
var _combat: Node


func _ready() -> void:
	# Cache autoload references once at startup
	_npc_db = get_node_or_null("/root/NPCDatabase")
	_gear_system = get_node_or_null("/root/GearSetSystem")
	_dungeon_system = get_node_or_null("/root/DungeonSystem")
	_rift_system = get_node_or_null("/root/MythicRiftSystem")
	_event_system = get_node_or_null("/root/SeasonalEventSystem")
	_inventory = get_node_or_null("/root/InventorySystem")
	_dialogue = get_node_or_null("/root/DialogueSystem")
	_combat = get_node_or_null("/root/CombatSystem")

func save_game() -> bool:
	var save_data: Dictionary = {
		"version": "2.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"player": {
			"position": {"x": 0, "y": 0},
			"money": EventBus.player_money,
			"energy": EventBus.player_energy,
			"ethereal_tokens": EventBus.ethereal_tokens,
			"active_gear_set": EventBus.active_gear_set,
		},
		"calendar": {
			"day": EventBus.current_day,
			"season": EventBus.current_season,
			"hour": EventBus.current_hour,
		},
		"farm": {},
		"inventory": _get_inventory_data(),
		"npc_friendships": _get_npc_friendship_data(),
		"dialogue": _get_dialogue_data(),
		"gear": _get_gear_data(),
		"dungeons": _get_dungeon_data(),
		"mythic_rift": _get_mythic_rift_data(),
		"events": _get_event_data(),
		"combat": _get_combat_data()
	}

	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		return true
	else:
		push_warning("SaveSystem: Failed to save game!")
		return false


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE):
		push_warning("SaveSystem: No save file found")
		return {}

	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		push_warning("SaveSystem: Failed to open save file")
		return {}

	var json_string: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error: int = json.parse(json_string)
	if error != OK:
		push_warning("SaveSystem: Failed to parse save file")
		return {}

	var data: Dictionary = json.data

	# Restore new system state
	if data.has("player"):
		if data.player.has("ethereal_tokens"):
			EventBus.ethereal_tokens = data.player.ethereal_tokens
		if data.player.has("active_gear_set"):
			EventBus.active_gear_set = data.player.active_gear_set

	_load_npc_friendship_data(data.get("npc_friendships", {}))
	_load_inventory_data(data.get("inventory", {}))
	_load_dialogue_data(data.get("dialogue", {}))
	_load_gear_data(data.get("gear", {}))
	_load_dungeon_data(data.get("dungeons", {}))
	_load_mythic_rift_data(data.get("mythic_rift", {}))
	_load_event_data(data.get("events", {}))
	_load_combat_data(data.get("combat", {}))

	return data


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)


func _get_npc_friendship_data() -> Dictionary:
	if _npc_db and _npc_db.has_method("get_all_npc_ids"):
		var data: Dictionary = {}
		for npc_id: String in _npc_db.get_all_npc_ids():
			var npc: Dictionary = _npc_db.get_npc(npc_id)
			data[npc_id] = {
				"friendship_level": npc.get("friendship_level", 0),
				"friendship_points": npc.get("friendship_points", 0)
			}
		return data
	return {}


func _load_npc_friendship_data(data: Dictionary) -> void:
	if _npc_db:
		for npc_id: String in data:
			var npc: Dictionary = _npc_db.get_npc(npc_id)
			if not npc.is_empty():
				npc["friendship_level"] = data[npc_id].get("friendship_level", 0)
				npc["friendship_points"] = data[npc_id].get("friendship_points", 0)


func _get_gear_data() -> Dictionary:
	if _gear_system and _gear_system.has_method("get_save_data"):
		return _gear_system.get_save_data()
	return {}


func _load_gear_data(data: Dictionary) -> void:
	if _gear_system and _gear_system.has_method("load_save_data"):
		_gear_system.load_save_data(data)


func _get_dungeon_data() -> Dictionary:
	if _dungeon_system and _dungeon_system.has_method("get_save_data"):
		return _dungeon_system.get_save_data()
	return {}


func _load_dungeon_data(data: Dictionary) -> void:
	if _dungeon_system and _dungeon_system.has_method("load_save_data"):
		_dungeon_system.load_save_data(data)


func _get_mythic_rift_data() -> Dictionary:
	if _rift_system and _rift_system.has_method("get_save_data"):
		return _rift_system.get_save_data()
	return {}


func _load_mythic_rift_data(data: Dictionary) -> void:
	if _rift_system and _rift_system.has_method("load_save_data"):
		_rift_system.load_save_data(data)


func _get_event_data() -> Dictionary:
	if _event_system and _event_system.has_method("get_save_data"):
		return _event_system.get_save_data()
	return {}


func _load_event_data(data: Dictionary) -> void:
	if _event_system and _event_system.has_method("load_save_data"):
		_event_system.load_save_data(data)


func _get_inventory_data() -> Dictionary:
	if _inventory and _inventory.has_method("get_save_data"):
		return _inventory.get_save_data()
	return {}


func _load_inventory_data(data: Dictionary) -> void:
	if _inventory and _inventory.has_method("load_save_data"):
		_inventory.load_save_data(data)


func _get_dialogue_data() -> Dictionary:
	if _dialogue and _dialogue.has_method("get_save_data"):
		return _dialogue.get_save_data()
	return {}


func _load_dialogue_data(data: Dictionary) -> void:
	if _dialogue and _dialogue.has_method("load_save_data"):
		_dialogue.load_save_data(data)


func _get_combat_data() -> Dictionary:
	if _combat and _combat.has_method("get_save_data"):
		return _combat.get_save_data()
	return {}


func _load_combat_data(data: Dictionary) -> void:
	if _combat and _combat.has_method("load_save_data"):
		_combat.load_save_data(data)
