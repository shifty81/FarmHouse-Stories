extends Node
## MythicRiftSystem - Manages procedurally generated Mythic Rift dungeons.
## Players bring Chronos Shards to the Void Anchor vendor to open daily randomized Rifts.
## Mythic Rifts offer better loot and Ethereal Tokens for gear upgrades.

## Rift tiers with increasing difficulty and rewards
const RIFT_TIERS = {
	1: {"name": "Minor Rift", "room_count": 6, "difficulty": 2, "token_reward": 1, "shard_cost": 1},
	2: {"name": "Standard Rift", "room_count": 8, "difficulty": 3, "token_reward": 2, "shard_cost": 2},
	3: {"name": "Greater Rift", "room_count": 10, "difficulty": 4, "token_reward": 4, "shard_cost": 3},
	4: {"name": "Supreme Rift", "room_count": 14, "difficulty": 5, "token_reward": 7, "shard_cost": 5},
	5: {"name": "Abyssal Rift", "room_count": 18, "difficulty": 7, "token_reward": 12, "shard_cost": 8}
}

## Mythic boss pool for randomized encounters
const MYTHIC_BOSSES = [
	{"id": "void_wraith", "name": "Void Wraith", "base_hp": 150, "base_attack": 12},
	{"id": "rift_golem", "name": "Rift Golem", "base_hp": 250, "base_attack": 10},
	{"id": "chrono_phantom", "name": "Chrono Phantom", "base_hp": 120, "base_attack": 18},
	{"id": "echo_dragon", "name": "Echo Dragon", "base_hp": 350, "base_attack": 15},
	{"id": "shadow_king", "name": "Shadow King", "base_hp": 200, "base_attack": 22},
	{"id": "crystal_horror", "name": "Crystal Horror", "base_hp": 300, "base_attack": 14},
	{"id": "temporal_beast", "name": "Temporal Beast", "base_hp": 180, "base_attack": 20},
	{"id": "void_empress", "name": "Void Empress", "base_hp": 400, "base_attack": 25}
]

## Mythic loot table (upgraded versions of standard drops)
const MYTHIC_LOOT = [
	"enhanced_iron", "void_crystal", "ethereal_fabric", "rift_gem",
	"chrono_dust", "shadow_essence", "mythic_ore", "abyssal_shard",
	"temporal_fragment", "echo_resonance", "void_thread", "mythic_herb"
]

## Vendor exchange items: item_id -> {token_cost, description}
var vendor_inventory: Dictionary = {}

## Player's Chronos Shard count
var chronos_shards: int = 0

## Current active mythic rift
var active_rift: Dictionary = {}
var rift_active: bool = false

## Daily rift seed (changes each in-game day)
var daily_seed: int = 0


func _ready():
	_initialize_vendor_inventory()
	EventBus.day_started.connect(_on_day_started)
	EventBus.mythic_rift_completed.connect(_on_rift_completed)


const SEASONS_TO_INT = {"Spring": 1, "Summer": 2, "Fall": 3, "Winter": 4}


func _on_day_started(_day: int, _season: String):
	daily_seed = _day * 1000 + SEASONS_TO_INT.get(_season, 0)
	rift_active = false
	active_rift = {}


func open_mythic_rift(tier: int) -> Dictionary:
	if tier < 1 or tier > 5:
		return {}

	var tier_data = RIFT_TIERS[tier]
	if chronos_shards < tier_data.shard_cost:
		return {}

	if rift_active:
		return {}

	chronos_shards -= tier_data.shard_cost
	rift_active = true

	# Generate randomized rift layout using daily seed
	var rng = RandomNumberGenerator.new()
	rng.seed = daily_seed + tier * 100

	var boss_index = rng.randi_range(0, MYTHIC_BOSSES.size() - 1)
	var boss = MYTHIC_BOSSES[boss_index].duplicate()
	boss.hp = boss.base_hp * tier_data.difficulty
	boss.attack = boss.base_attack * (1 + tier * 0.3)

	# Generate loot for this rift
	var rift_loot = []
	for i in range(tier_data.difficulty + 2):
		var loot_index = rng.randi_range(0, MYTHIC_LOOT.size() - 1)
		rift_loot.append(MYTHIC_LOOT[loot_index])

	active_rift = {
		"tier": tier,
		"tier_name": tier_data.name,
		"room_count": tier_data.room_count,
		"difficulty": tier_data.difficulty,
		"boss": boss,
		"loot_table": rift_loot,
		"token_reward": tier_data.token_reward,
		"seed": daily_seed + tier
	}

	EventBus.mythic_rift_opened.emit(tier)
	return active_rift


func complete_mythic_rift() -> Dictionary:
	if not rift_active:
		return {}

	var rewards = {
		"ethereal_tokens": active_rift.get("token_reward", 0),
		"loot": active_rift.get("loot_table", []),
		"tier": active_rift.get("tier", 1)
	}

	EventBus.ethereal_tokens += rewards.ethereal_tokens
	EventBus.ethereal_tokens_changed.emit(EventBus.ethereal_tokens)

	EventBus.mythic_rift_completed.emit(active_rift.get("tier", 1), rewards)

	rift_active = false
	active_rift = {}
	return rewards


func add_chronos_shard(count: int = 1) -> void:
	chronos_shards += count
	EventBus.chronos_shard_obtained.emit()


func exchange_with_vendor(item_id: String) -> bool:
	if not vendor_inventory.has(item_id):
		return false

	var item = vendor_inventory[item_id]
	var cost = item.get("token_cost", 0)

	if EventBus.ethereal_tokens < cost:
		return false

	EventBus.ethereal_tokens -= cost
	EventBus.ethereal_tokens_changed.emit(EventBus.ethereal_tokens)
	EventBus.vendor_item_exchanged.emit(item_id, cost)
	return true


func _on_rift_completed(_tier: int, _rewards: Dictionary):
	pass


func _initialize_vendor_inventory():
	vendor_inventory = {
		"dungeon_helm_upgrade": {
			"name": "Helm Reinforcement Kit",
			"description": "Upgrades dungeon headgear to the next tier.",
			"token_cost": 5,
			"type": "upgrade_material",
			"target_slot": "head"
		},
		"dungeon_armor_upgrade": {
			"name": "Armor Reinforcement Kit",
			"description": "Upgrades dungeon body armor to the next tier.",
			"token_cost": 8,
			"type": "upgrade_material",
			"target_slot": "body"
		},
		"dungeon_boots_upgrade": {
			"name": "Boot Reinforcement Kit",
			"description": "Upgrades dungeon footwear to the next tier.",
			"token_cost": 4,
			"type": "upgrade_material",
			"target_slot": "feet"
		},
		"magnetic_boots": {
			"name": "Magnetic Boots",
			"description": "Specialized boots that allow walking on metallic dungeon surfaces and solving magnetic puzzles.",
			"token_cost": 15,
			"type": "gear",
			"slot": "feet",
			"stats": {"defense": 4, "move_speed": 1.0, "trap_resist": 1.5, "magnetic": true}
		},
		"rift_cloak": {
			"name": "Rift-Woven Cloak",
			"description": "A magical cape woven from Rift energy that provides resistance to void damage.",
			"token_cost": 20,
			"type": "gear",
			"slot": "accessory",
			"stats": {"void_resist": 2.0, "mana_regen": 1.5, "rift_sight": true}
		},
		"chrono_compass": {
			"name": "Chrono Compass",
			"description": "Reveals hidden rooms and shortcuts in dungeons.",
			"token_cost": 12,
			"type": "tool",
			"stats": {"dungeon_vision": true, "secret_detect": 1.5}
		},
		"ethereal_health_potion": {
			"name": "Ethereal Health Draught",
			"description": "Potent healing potion that restores a large amount of HP in dungeons.",
			"token_cost": 3,
			"type": "consumable",
			"heal_amount": 100
		},
		"void_shield_charm": {
			"name": "Void Shield Charm",
			"description": "Grants a temporary shield that absorbs one fatal blow.",
			"token_cost": 10,
			"type": "consumable",
			"shield_hits": 1
		}
	}


func get_save_data() -> Dictionary:
	return {
		"chronos_shards": chronos_shards,
		"rift_active": rift_active,
		"daily_seed": daily_seed
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("chronos_shards"):
		chronos_shards = data.chronos_shards
	if data.has("daily_seed"):
		daily_seed = data.daily_seed
