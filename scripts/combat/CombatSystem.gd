extends Node
## CombatSystem - Manages player combat stats, enemy encounters, damage calculation,
## and combat flow within dungeons. Integrates with GearSetSystem for stat bonuses.

## Player combat state
var player_hp: int = 100
var player_max_hp: int = 100
var player_attack: int = 10
var player_defense: int = 5
var is_in_combat: bool = false

## Active enemies in the current room
var active_enemies: Array = []

## Enemy templates indexed by enemy_id
var enemy_registry: Dictionary = {}


func _ready():
	_register_enemies()
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.dungeon_exited.connect(_on_dungeon_exited)
	EventBus.dungeon_room_cleared.connect(_on_room_cleared)


func _register_enemies():
	# Echo Caverns enemies (Difficulty 1)
	_register_enemy("cave_bat", "Cave Bat", 15, 4, 1, {
		"xp": 5, "drops": [{"item_id": "copper_ore", "chance": 0.3}]
	})
	_register_enemy("slime", "Slime", 20, 3, 2, {
		"xp": 7, "drops": [{"item_id": "medicinal_herb", "chance": 0.2}]
	})
	_register_enemy("stone_golem", "Stone Golem", 35, 6, 5, {
		"xp": 12, "drops": [{"item_id": "iron_ore", "chance": 0.4}]
	})

	# Whispering Depths enemies (Difficulty 2)
	_register_enemy("shadow_wisp", "Shadow Wisp", 25, 7, 2, {
		"xp": 10, "drops": [{"item_id": "echo_crystal", "chance": 0.25}]
	})
	_register_enemy("rift_spider", "Rift Spider", 30, 8, 3, {
		"xp": 14, "drops": [{"item_id": "medicinal_herb", "chance": 0.3}]
	})

	# Crystal Sanctum enemies (Difficulty 3)
	_register_enemy("crystal_guardian", "Crystal Guardian", 50, 10, 8, {
		"xp": 25, "drops": [{"item_id": "echo_crystal", "chance": 0.5}]
	})
	_register_enemy("prism_wraith", "Prism Wraith", 40, 12, 5, {
		"xp": 20, "drops": [{"item_id": "void_fragment", "chance": 0.15}]
	})

	# Ember Forge enemies (Difficulty 4)
	_register_enemy("fire_elemental", "Fire Elemental", 60, 14, 7, {
		"xp": 30, "drops": [{"item_id": "iron_ore", "chance": 0.5}]
	})
	_register_enemy("molten_crawler", "Molten Crawler", 55, 11, 10, {
		"xp": 28, "drops": [{"item_id": "copper_ore", "chance": 0.6}]
	})

	# Void Fortress enemies (Difficulty 5)
	_register_enemy("void_sentinel", "Void Sentinel", 80, 16, 12, {
		"xp": 45, "drops": [{"item_id": "void_fragment", "chance": 0.4}]
	})
	_register_enemy("echo_phantom", "Echo Phantom", 70, 18, 8, {
		"xp": 40, "drops": [{"item_id": "echo_crystal", "chance": 0.5}]
	})

	# Dungeon bosses
	_register_enemy("stone_sentinel", "Stone Sentinel", 120, 12, 15, {
		"xp": 100, "is_boss": true,
		"drops": [
			{"item_id": "chronos_shard", "chance": 1.0},
			{"item_id": "iron_ore", "chance": 1.0, "quantity": 5}
		]
	})
	_register_enemy("whisper_queen", "Whisper Queen", 150, 15, 12, {
		"xp": 150, "is_boss": true,
		"drops": [
			{"item_id": "chronos_shard", "chance": 1.0},
			{"item_id": "echo_crystal", "chance": 1.0, "quantity": 3}
		]
	})
	_register_enemy("crystal_colossus", "Crystal Colossus", 200, 18, 20, {
		"xp": 200, "is_boss": true,
		"drops": [
			{"item_id": "chronos_shard", "chance": 1.0},
			{"item_id": "void_fragment", "chance": 0.5, "quantity": 2}
		]
	})
	_register_enemy("ember_lord", "Ember Lord", 250, 22, 18, {
		"xp": 250, "is_boss": true,
		"drops": [
			{"item_id": "chronos_shard", "chance": 1.0},
			{"item_id": "ethereal_token", "chance": 1.0, "quantity": 3}
		]
	})
	_register_enemy("void_emperor", "Void Emperor", 350, 28, 25, {
		"xp": 400, "is_boss": true,
		"drops": [
			{"item_id": "chronos_shard", "chance": 1.0, "quantity": 2},
			{"item_id": "ethereal_token", "chance": 1.0, "quantity": 5},
			{"item_id": "void_fragment", "chance": 1.0, "quantity": 3}
		]
	})


func _register_enemy(id: String, display_name: String, hp: int, attack: int, defense: int, data: Dictionary):
	enemy_registry[id] = {
		"id": id,
		"name": display_name,
		"max_hp": hp,
		"attack": attack,
		"defense": defense,
		"data": data
	}


## Spawn enemies for a combat encounter. Returns the list of spawned enemies.
func spawn_enemies(enemy_ids: Array) -> Array:
	active_enemies.clear()

	for enemy_id in enemy_ids:
		if enemy_registry.has(enemy_id):
			var template = enemy_registry[enemy_id]
			var enemy = {
				"id": template.id,
				"name": template.name,
				"hp": template.max_hp,
				"max_hp": template.max_hp,
				"attack": template.attack,
				"defense": template.defense,
				"data": template.data.duplicate(true)
			}
			active_enemies.append(enemy)

	if not active_enemies.is_empty():
		is_in_combat = true

	return active_enemies


## Calculate damage dealt from attacker to defender.
## Returns the actual damage dealt after defense reduction.
func calculate_damage(attack_power: int, defense: int) -> int:
	var raw_damage = maxi(1, attack_power - defense)
	# Add slight randomness (±15%)
	var variance = randf_range(0.85, 1.15)
	return maxi(1, roundi(raw_damage * variance))


## Player attacks a specific enemy (by index in active_enemies).
## Returns a result dictionary with damage dealt and enemy status.
func player_attack_enemy(enemy_index: int) -> Dictionary:
	if enemy_index < 0 or enemy_index >= active_enemies.size():
		return {}

	var enemy = active_enemies[enemy_index]
	var total_attack = _get_player_total_attack()
	var damage = calculate_damage(total_attack, enemy.defense)
	enemy.hp = maxi(0, enemy.hp - damage)

	var result = {
		"damage": damage,
		"enemy_name": enemy.name,
		"enemy_hp": enemy.hp,
		"enemy_max_hp": enemy.max_hp,
		"is_defeated": enemy.hp <= 0
	}

	if enemy.hp <= 0:
		result["rewards"] = _process_enemy_defeat(enemy)

	return result


## Enemy attacks the player. Returns a result dictionary.
func enemy_attack_player(enemy_index: int) -> Dictionary:
	if enemy_index < 0 or enemy_index >= active_enemies.size():
		return {}

	var enemy = active_enemies[enemy_index]
	var total_defense = _get_player_total_defense()
	var damage = calculate_damage(enemy.attack, total_defense)
	player_hp = maxi(0, player_hp - damage)

	var result = {
		"damage": damage,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"is_defeated": player_hp <= 0
	}

	return result


## Use a consumable item during combat (e.g., health potion).
func use_combat_item(item_id: String) -> Dictionary:
	var inventory = get_node_or_null("/root/InventorySystem")
	if not inventory:
		return {"success": false}

	var item_info = inventory.get_item_info(item_id)
	if item_info.is_empty():
		return {"success": false}

	var data = item_info.get("data", {})
	var effect_type = data.get("effect_type", "")

	if effect_type == "heal_hp":
		var heal_amount = data.get("effect_value", 0)
		var old_hp = player_hp
		player_hp = mini(player_hp + heal_amount, player_max_hp)
		inventory.remove_item(item_id, 1)
		return {
			"success": true,
			"effect": "heal",
			"amount": player_hp - old_hp,
			"player_hp": player_hp
		}

	return {"success": false}


## Check if all enemies in the current encounter are defeated.
func is_encounter_cleared() -> bool:
	for enemy in active_enemies:
		if enemy.hp > 0:
			return false
	return true


## End the current combat encounter.
func end_combat():
	is_in_combat = false
	active_enemies.clear()


## Fully heal the player (e.g., on returning home or sleeping).
func full_heal():
	player_hp = player_max_hp


## Get enemy info from the registry.
func get_enemy_info(enemy_id: String) -> Dictionary:
	return enemy_registry.get(enemy_id, {})


## Get enemies appropriate for a dungeon difficulty level.
func get_enemies_for_difficulty(difficulty: int) -> Array:
	var suitable = []
	for enemy_id in enemy_registry:
		var enemy = enemy_registry[enemy_id]
		var is_boss = enemy.data.get("is_boss", false)
		if is_boss:
			continue
		# Rough difficulty mapping based on HP thresholds
		var hp = enemy.max_hp
		if difficulty <= 1 and hp <= 35:
			suitable.append(enemy_id)
		elif difficulty == 2 and hp > 20 and hp <= 50:
			suitable.append(enemy_id)
		elif difficulty == 3 and hp > 35 and hp <= 60:
			suitable.append(enemy_id)
		elif difficulty == 4 and hp > 50 and hp <= 80:
			suitable.append(enemy_id)
		elif difficulty >= 5 and hp > 60:
			suitable.append(enemy_id)
	return suitable


## Get player's total attack power including gear bonuses.
func _get_player_total_attack() -> int:
	var gear_system = get_node_or_null("/root/GearSetSystem")
	var bonus = 0
	if gear_system:
		var stats = gear_system.get_total_stats()
		bonus = int(stats.get("attack", 0))
	return player_attack + bonus


## Get player's total defense including gear bonuses.
func _get_player_total_defense() -> int:
	var gear_system = get_node_or_null("/root/GearSetSystem")
	var bonus = 0
	if gear_system:
		var stats = gear_system.get_total_stats()
		bonus = int(stats.get("defense", 0))
	return player_defense + bonus


## Process rewards when an enemy is defeated.
func _process_enemy_defeat(enemy: Dictionary) -> Dictionary:
	var rewards = {"xp": 0, "items": []}
	var enemy_data = enemy.get("data", {})

	rewards.xp = enemy_data.get("xp", 0)

	# Process loot drops
	var drops = enemy_data.get("drops", [])
	var inventory = get_node_or_null("/root/InventorySystem")

	for drop in drops:
		var roll = randf()
		if roll <= drop.get("chance", 0):
			var item_id = drop.get("item_id", "")
			var quantity = drop.get("quantity", 1)
			if item_id != "" and inventory:
				inventory.add_item(item_id, quantity)
				rewards.items.append({"item_id": item_id, "quantity": quantity})

	# Check if this was a boss
	if enemy_data.get("is_boss", false):
		EventBus.dungeon_boss_defeated.emit(enemy.id)

	# Remove defeated enemy from active list
	active_enemies.erase(enemy)

	# Check if encounter is cleared
	if is_encounter_cleared():
		is_in_combat = false
		EventBus.dungeon_room_cleared.emit(enemy.get("id", ""))

	return rewards


func _on_dungeon_entered(_dungeon_id: String):
	full_heal()


func _on_dungeon_exited(_dungeon_id: String):
	end_combat()
	full_heal()


func _on_room_cleared(_room_id: String):
	if is_in_combat and is_encounter_cleared():
		end_combat()


## Save combat state.
func get_save_data() -> Dictionary:
	return {
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_attack": player_attack,
		"player_defense": player_defense
	}


## Load combat state.
func load_save_data(data: Dictionary) -> void:
	if data.has("player_hp"):
		player_hp = data.player_hp
	if data.has("player_max_hp"):
		player_max_hp = data.player_max_hp
	if data.has("player_attack"):
		player_attack = data.player_attack
	if data.has("player_defense"):
		player_defense = data.player_defense
