extends Node
## GearSetSystem - Manages dual gear sets (Farm Set and Dungeon Set).
## Players wear the Farm Set for daily life and the Dungeon Set for combat/exploration.

## Gear slot definitions
const GEAR_SLOTS = ["head", "body", "legs", "feet", "accessory", "tool"]
const MAX_UPGRADE_LEVEL: int = 5

## Current equipment per set: { slot_name: item_data }
var farm_set: Dictionary = {}
var dungeon_set: Dictionary = {}

## Which set is currently active
var active_set: String = "farm"


func _ready():
	_initialize_default_sets()
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.dungeon_exited.connect(_on_dungeon_exited)


func _initialize_default_sets():
	for slot in GEAR_SLOTS:
		farm_set[slot] = null
		dungeon_set[slot] = null

	# Default farm set starter gear
	farm_set["body"] = _create_gear_item("farm_shirt", "Farmer's Shirt", "farm", "body", {
		"stamina_regen": 1.5, "move_speed": 1.1, "interaction_bonus": 1.2
	})
	farm_set["legs"] = _create_gear_item("farm_overalls", "Work Overalls", "farm", "legs", {
		"stamina_regen": 1.0, "harvest_bonus": 1.1
	})
	farm_set["feet"] = _create_gear_item("farm_boots", "Muddy Boots", "farm", "feet", {
		"move_speed": 1.05, "soil_quality": 1.1
	})

	# Default dungeon set starter gear
	dungeon_set["body"] = _create_gear_item("leather_armor", "Leather Armor", "dungeon", "body", {
		"defense": 5, "hp_bonus": 10
	})
	dungeon_set["feet"] = _create_gear_item("iron_boots", "Iron Boots", "dungeon", "feet", {
		"defense": 2, "move_speed": 0.95, "trap_resist": 1.2
	})


func switch_to_set(set_type: String) -> bool:
	if set_type != "farm" and set_type != "dungeon":
		return false
	if set_type == active_set:
		return false

	active_set = set_type
	EventBus.active_gear_set = set_type
	EventBus.gear_set_changed.emit(set_type)
	return true


func get_active_set() -> Dictionary:
	if active_set == "farm":
		return farm_set
	return dungeon_set


func equip_item(set_type: String, slot: String, item: Dictionary) -> Dictionary:
	if slot not in GEAR_SLOTS:
		return {}

	var target_set = farm_set if set_type == "farm" else dungeon_set
	var old_item = target_set[slot]
	target_set[slot] = item
	EventBus.gear_equipped.emit(slot, item.get("id", ""))
	return old_item if old_item else {}


func unequip_item(set_type: String, slot: String) -> Dictionary:
	var target_set = farm_set if set_type == "farm" else dungeon_set
	var old_item = target_set.get(slot)
	target_set[slot] = null
	return old_item if old_item else {}


func get_total_stats(set_type: String = "") -> Dictionary:
	if set_type == "":
		set_type = active_set

	var target_set = farm_set if set_type == "farm" else dungeon_set
	var total_stats = {}

	for slot in GEAR_SLOTS:
		var item = target_set.get(slot)
		if item and item.has("stats"):
			for stat_name in item.stats:
				if total_stats.has(stat_name):
					total_stats[stat_name] += item.stats[stat_name]
				else:
					total_stats[stat_name] = item.stats[stat_name]

	return total_stats


func upgrade_dungeon_gear(slot: String, tokens_required: int) -> bool:
	if EventBus.ethereal_tokens < tokens_required:
		return false

	var item = dungeon_set.get(slot)
	if not item:
		return false

	var current_level = item.get("upgrade_level", 0)
	if current_level >= MAX_UPGRADE_LEVEL:
		return false

	EventBus.ethereal_tokens -= tokens_required
	EventBus.ethereal_tokens_changed.emit(EventBus.ethereal_tokens)

	item.upgrade_level = current_level + 1

	# Boost all stats by 15% per upgrade level
	if item.has("stats"):
		for stat_name in item.stats:
			item.stats[stat_name] *= 1.15

	EventBus.gear_upgraded.emit(item.get("id", ""), item.upgrade_level)
	return true


func _on_dungeon_entered(_dungeon_id: String):
	switch_to_set("dungeon")


func _on_dungeon_exited(_dungeon_id: String):
	switch_to_set("farm")


func _create_gear_item(id: String, name: String, set_type: String, slot: String, stats: Dictionary) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"set_type": set_type,
		"slot": slot,
		"stats": stats,
		"upgrade_level": 0,
		"description": ""
	}


func get_save_data() -> Dictionary:
	return {
		"active_set": active_set,
		"farm_set": farm_set.duplicate(true),
		"dungeon_set": dungeon_set.duplicate(true)
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("active_set"):
		active_set = data.active_set
	if data.has("farm_set"):
		farm_set = data.farm_set
	if data.has("dungeon_set"):
		dungeon_set = data.dungeon_set
