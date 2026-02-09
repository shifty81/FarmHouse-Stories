extends Node
## SaveSystem - Handles saving and loading game state to/from disk.

const SAVE_FILE = "user://farmhouse_save.json"

func save_game() -> bool:
	var save_data = {
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

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully!")
		return true
	else:
		print("Failed to save game!")
		return false


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found")
		return {}

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		print("Failed to open save file")
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("Failed to parse save file")
		return {}

	var data = json.data

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

	print("Game loaded successfully!")
	return data


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)


func _get_npc_friendship_data() -> Dictionary:
	var npc_db = get_node_or_null("/root/NPCDatabase")
	if npc_db and npc_db.has_method("get_all_npc_ids"):
		var data = {}
		for npc_id in npc_db.get_all_npc_ids():
			var npc = npc_db.get_npc(npc_id)
			data[npc_id] = {
				"friendship_level": npc.get("friendship_level", 0),
				"friendship_points": npc.get("friendship_points", 0)
			}
		return data
	return {}


func _load_npc_friendship_data(data: Dictionary) -> void:
	var npc_db = get_node_or_null("/root/NPCDatabase")
	if npc_db:
		for npc_id in data:
			var npc = npc_db.get_npc(npc_id)
			if not npc.is_empty():
				npc["friendship_level"] = data[npc_id].get("friendship_level", 0)
				npc["friendship_points"] = data[npc_id].get("friendship_points", 0)


func _get_gear_data() -> Dictionary:
	var gear_system = get_node_or_null("/root/GearSetSystem")
	if gear_system and gear_system.has_method("get_save_data"):
		return gear_system.get_save_data()
	return {}


func _load_gear_data(data: Dictionary) -> void:
	var gear_system = get_node_or_null("/root/GearSetSystem")
	if gear_system and gear_system.has_method("load_save_data"):
		gear_system.load_save_data(data)


func _get_dungeon_data() -> Dictionary:
	var dungeon_system = get_node_or_null("/root/DungeonSystem")
	if dungeon_system and dungeon_system.has_method("get_save_data"):
		return dungeon_system.get_save_data()
	return {}


func _load_dungeon_data(data: Dictionary) -> void:
	var dungeon_system = get_node_or_null("/root/DungeonSystem")
	if dungeon_system and dungeon_system.has_method("load_save_data"):
		dungeon_system.load_save_data(data)


func _get_mythic_rift_data() -> Dictionary:
	var rift_system = get_node_or_null("/root/MythicRiftSystem")
	if rift_system and rift_system.has_method("get_save_data"):
		return rift_system.get_save_data()
	return {}


func _load_mythic_rift_data(data: Dictionary) -> void:
	var rift_system = get_node_or_null("/root/MythicRiftSystem")
	if rift_system and rift_system.has_method("load_save_data"):
		rift_system.load_save_data(data)


func _get_event_data() -> Dictionary:
	var event_system = get_node_or_null("/root/SeasonalEventSystem")
	if event_system and event_system.has_method("get_save_data"):
		return event_system.get_save_data()
	return {}


func _load_event_data(data: Dictionary) -> void:
	var event_system = get_node_or_null("/root/SeasonalEventSystem")
	if event_system and event_system.has_method("load_save_data"):
		event_system.load_save_data(data)


func _get_inventory_data() -> Dictionary:
	var inventory = get_node_or_null("/root/InventorySystem")
	if inventory and inventory.has_method("get_save_data"):
		return inventory.get_save_data()
	return {}


func _load_inventory_data(data: Dictionary) -> void:
	var inventory = get_node_or_null("/root/InventorySystem")
	if inventory and inventory.has_method("load_save_data"):
		inventory.load_save_data(data)


func _get_dialogue_data() -> Dictionary:
	var dialogue = get_node_or_null("/root/DialogueSystem")
	if dialogue and dialogue.has_method("get_save_data"):
		return dialogue.get_save_data()
	return {}


func _load_dialogue_data(data: Dictionary) -> void:
	var dialogue = get_node_or_null("/root/DialogueSystem")
	if dialogue and dialogue.has_method("load_save_data"):
		dialogue.load_save_data(data)


func _get_combat_data() -> Dictionary:
	var combat = get_node_or_null("/root/CombatSystem")
	if combat and combat.has_method("get_save_data"):
		return combat.get_save_data()
	return {}


func _load_combat_data(data: Dictionary) -> void:
	var combat = get_node_or_null("/root/CombatSystem")
	if combat and combat.has_method("load_save_data"):
		combat.load_save_data(data)
