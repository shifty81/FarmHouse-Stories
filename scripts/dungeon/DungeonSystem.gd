extends Node
## DungeonSystem - Manages dungeon generation, room layouts, puzzles, and bosses.
## Inspired by Link to the Past style dungeons with keys, puzzles, and boss encounters.

## Dungeon room types for procedural layout
const ROOM_TYPES = ["combat", "puzzle", "treasure", "key", "boss", "entrance", "corridor", "trap"]

## Puzzle types found in dungeons
const PUZZLE_TYPES = [
	"block_push", "switch_sequence", "light_reflection",
	"pressure_plate", "torch_lighting", "tile_pattern",
	"water_flow", "crystal_alignment", "lever_order"
]

## Key types needed to progress through dungeons
const KEY_TYPES = ["small_key", "big_key", "boss_key", "crystal_key"]

## Story dungeon definitions (fixed layouts in Echo Ridge)
var story_dungeons: Dictionary = {}

## Currently active dungeon state
var active_dungeon: Dictionary = {}
var rooms_cleared: Array = []
var keys_held: Dictionary = {}
var dungeon_active: bool = false


func _ready():
	_register_story_dungeons()
	EventBus.dungeon_room_cleared.connect(_on_room_cleared)
	EventBus.dungeon_key_obtained.connect(_on_key_obtained)


func enter_dungeon(dungeon_id: String) -> Dictionary:
	if not story_dungeons.has(dungeon_id):
		return {}

	active_dungeon = story_dungeons[dungeon_id].duplicate(true)
	rooms_cleared = []
	keys_held = {"small_key": 0, "big_key": 0, "boss_key": 0, "crystal_key": 0}
	dungeon_active = true

	EventBus.current_dungeon = dungeon_id
	EventBus.dungeon_entered.emit(dungeon_id)
	return active_dungeon


func exit_dungeon() -> void:
	var dungeon_id = active_dungeon.get("id", "")
	active_dungeon = {}
	rooms_cleared = []
	keys_held = {}
	dungeon_active = false

	EventBus.current_dungeon = ""
	EventBus.dungeon_exited.emit(dungeon_id)


func get_dungeon_info(dungeon_id: String) -> Dictionary:
	return story_dungeons.get(dungeon_id, {})


func get_all_dungeon_ids() -> Array:
	return story_dungeons.keys()


func use_key(key_type: String) -> bool:
	if keys_held.get(key_type, 0) > 0:
		keys_held[key_type] -= 1
		return true
	return false


func _on_room_cleared(room_id: String):
	if room_id not in rooms_cleared:
		rooms_cleared.append(room_id)


func _on_key_obtained(key_type: String):
	keys_held[key_type] = keys_held.get(key_type, 0) + 1


func generate_dungeon_layout(room_count: int, difficulty: int) -> Array:
	var layout = []
	layout.append({"id": "room_0", "type": "entrance", "connections": [1]})

	for i in range(1, room_count - 1):
		var room_type = ROOM_TYPES[i % ROOM_TYPES.size()]
		if i == room_count / 2:
			room_type = "key"
		var connections = [i - 1]
		if i < room_count - 1:
			connections.append(i + 1)
		# Add branch paths for higher difficulty
		if difficulty >= 3 and i % 3 == 0 and i + 2 < room_count:
			connections.append(i + 2)
		layout.append({
			"id": "room_%d" % i,
			"type": room_type,
			"connections": connections,
			"difficulty": difficulty,
			"puzzle_type": PUZZLE_TYPES[i % PUZZLE_TYPES.size()] if room_type == "puzzle" else ""
		})

	layout.append({
		"id": "room_%d" % (room_count - 1),
		"type": "boss",
		"connections": [room_count - 2],
		"difficulty": difficulty + 1
	})

	return layout


func _register_story_dungeons():
	story_dungeons["echo_caverns"] = {
		"id": "echo_caverns",
		"name": "Echo Caverns",
		"description": "The first dungeon beneath Echo Ridge. Ancient stone corridors echo with the whispers of the past.",
		"difficulty": 1,
		"room_count": 8,
		"required_item": "",
		"boss": {
			"id": "stone_sentinel",
			"name": "Stone Sentinel",
			"hp": 100,
			"attack": 8,
			"weakness": "bomb",
			"drops": ["cavern_key", "iron_ore", "chronos_shard_fragment"]
		},
		"loot_table": ["iron_ore", "small_crystal", "leather_scrap", "healing_herb", "small_key"],
		"puzzle_types": ["block_push", "switch_sequence", "pressure_plate"],
		"unlock_item": "echo_crystal"
	}

	story_dungeons["whispering_depths"] = {
		"id": "whispering_depths",
		"name": "Whispering Depths",
		"description": "Deeper passages where Rift energy seeps through ancient walls. Strange creatures lurk in the shadows.",
		"difficulty": 2,
		"room_count": 10,
		"required_item": "echo_crystal",
		"boss": {
			"id": "shadow_weaver",
			"name": "Shadow Weaver",
			"hp": 180,
			"attack": 14,
			"weakness": "light_arrow",
			"drops": ["shadow_cloak", "void_shard", "chronos_shard_fragment"]
		},
		"loot_table": ["shadow_silk", "void_shard", "rift_ore", "mana_potion", "small_key"],
		"puzzle_types": ["torch_lighting", "light_reflection", "tile_pattern"],
		"unlock_item": "shadow_medallion"
	}

	story_dungeons["crystal_sanctum"] = {
		"id": "crystal_sanctum",
		"name": "Crystal Sanctum",
		"description": "A cathedral of living crystals that amplify Rift energy. The walls pulse with otherworldly light.",
		"difficulty": 3,
		"room_count": 12,
		"required_item": "shadow_medallion",
		"boss": {
			"id": "crystal_guardian",
			"name": "Crystal Guardian",
			"hp": 280,
			"attack": 20,
			"weakness": "magnetic_boots",
			"drops": ["crystal_heart", "ethereal_token", "chronos_shard"]
		},
		"loot_table": ["rift_crystal", "ethereal_dust", "crystal_shard", "greater_mana_potion", "crystal_key"],
		"puzzle_types": ["crystal_alignment", "water_flow", "lever_order"],
		"unlock_item": "crystal_resonator"
	}

	story_dungeons["void_fortress"] = {
		"id": "void_fortress",
		"name": "Void Fortress",
		"description": "The deepest dungeon at the heart of Echo Ridge. Reality itself bends within these halls.",
		"difficulty": 5,
		"room_count": 16,
		"required_item": "crystal_resonator",
		"boss": {
			"id": "rift_lord",
			"name": "The Rift Lord",
			"hp": 500,
			"attack": 35,
			"weakness": "legendary_blade",
			"drops": ["rift_crown", "ethereal_token", "void_essence", "chronos_shard"]
		},
		"loot_table": ["void_metal", "ethereal_token", "rift_gem", "legendary_material", "boss_key"],
		"puzzle_types": ["block_push", "crystal_alignment", "torch_lighting", "lever_order", "tile_pattern"],
		"unlock_item": "void_seal"
	}

	story_dungeons["ancient_aqueducts"] = {
		"id": "ancient_aqueducts",
		"name": "Ancient Aqueducts",
		"description": "Waterlogged tunnels from an ancient civilization. Currents shift with the Rift tides.",
		"difficulty": 2,
		"room_count": 10,
		"required_item": "cavern_key",
		"boss": {
			"id": "tide_serpent",
			"name": "Tide Serpent",
			"hp": 200,
			"attack": 16,
			"weakness": "ice_arrow",
			"drops": ["serpent_scale", "water_gem", "chronos_shard_fragment"]
		},
		"loot_table": ["water_gem", "coral_piece", "ancient_coin", "stamina_potion", "small_key"],
		"puzzle_types": ["water_flow", "pressure_plate", "switch_sequence"],
		"unlock_item": "aqueduct_seal"
	}

	story_dungeons["ember_forge"] = {
		"id": "ember_forge",
		"name": "Ember Forge",
		"description": "A volcanic dungeon where ancient forges still burn. The heat is almost unbearable without proper gear.",
		"difficulty": 4,
		"room_count": 14,
		"required_item": "aqueduct_seal",
		"boss": {
			"id": "forge_titan",
			"name": "Forge Titan",
			"hp": 400,
			"attack": 28,
			"weakness": "water_gem",
			"drops": ["titan_hammer", "fire_crystal", "ethereal_token", "chronos_shard"]
		},
		"loot_table": ["fire_crystal", "molten_ore", "obsidian_shard", "fire_resist_potion", "boss_key"],
		"puzzle_types": ["torch_lighting", "lever_order", "tile_pattern", "crystal_alignment"],
		"unlock_item": "ember_heart"
	}


func get_save_data() -> Dictionary:
	return {
		"rooms_cleared_by_dungeon": {},
		"dungeon_active": dungeon_active,
		"active_dungeon_id": active_dungeon.get("id", ""),
		"keys_held": keys_held.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("dungeon_active"):
		dungeon_active = data.dungeon_active
	if data.has("keys_held"):
		keys_held = data.keys_held
	if data.has("active_dungeon_id") and data.active_dungeon_id != "":
		enter_dungeon(data.active_dungeon_id)