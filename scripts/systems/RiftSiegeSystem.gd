extends Node
## RiftSiegeSystem - Manages periodic Rift Siege events that besiege the town.
## During a siege, NPCs may need assistance or refuge, and specialized gear is
## required to clear the Rift Dungeons that spawn.

## Siege difficulty tiers
const SIEGE_TIERS = {
	1: {"name": "Minor Incursion", "duration_hours": 6, "npc_affected_count": 3, "dungeon_difficulty": 1},
	2: {"name": "Rift Storm", "duration_hours": 12, "npc_affected_count": 6, "dungeon_difficulty": 2},
	3: {"name": "Void Breach", "duration_hours": 18, "npc_affected_count": 10, "dungeon_difficulty": 3},
	4: {"name": "Abyssal Siege", "duration_hours": 24, "npc_affected_count": 15, "dungeon_difficulty": 5}
}

## Types of assistance NPCs may need during a siege
const ASSISTANCE_TYPES = ["escort_to_shelter", "medical_aid", "supply_delivery", "structural_repair", "defense_support"]

## Current siege state
var siege_active: bool = false
var active_siege: Dictionary = {}
var affected_npcs: Array = []
var sheltered_npcs: Array = []
var siege_start_hour: int = 0

## Shelter locations where NPCs can take refuge
const SHELTER_LOCATIONS = ["town_hall", "chapel", "tavern", "guard_barracks"]


func _ready():
	EventBus.day_started.connect(_on_day_started)


func start_siege(tier: int) -> Dictionary:
	if tier < 1 or tier > 4:
		return {}

	if siege_active:
		return {}

	var tier_data = SIEGE_TIERS[tier]
	siege_active = true
	siege_start_hour = EventBus.current_hour
	sheltered_npcs = []

	active_siege = {
		"tier": tier,
		"name": tier_data.name,
		"duration_hours": tier_data.duration_hours,
		"dungeon_difficulty": tier_data.dungeon_difficulty,
		"start_hour": siege_start_hour,
		"npcs_needing_help": []
	}

	# Determine affected NPCs
	affected_npcs = _select_affected_npcs(tier_data.npc_affected_count)
	for npc_id in affected_npcs:
		var assistance = ASSISTANCE_TYPES[hash(npc_id) % ASSISTANCE_TYPES.size()]
		active_siege.npcs_needing_help.append({
			"npc_id": npc_id,
			"assistance_type": assistance,
			"helped": false
		})
		EventBus.npc_needs_assistance.emit(npc_id, assistance)

	EventBus.rift_siege_started.emit("siege_tier_%d" % tier)
	return active_siege


func end_siege() -> Dictionary:
	if not siege_active:
		return {}

	var results = {
		"tier": active_siege.get("tier", 1),
		"npcs_helped": sheltered_npcs.size(),
		"npcs_affected": affected_npcs.size(),
		"siege_name": active_siege.get("name", "")
	}

	var siege_id = "siege_tier_%d" % active_siege.get("tier", 1)
	siege_active = false
	active_siege = {}
	affected_npcs = []
	sheltered_npcs = []

	EventBus.rift_siege_ended.emit(siege_id)
	return results


func shelter_npc(npc_id: String) -> bool:
	if not siege_active:
		return false

	if npc_id not in affected_npcs:
		return false

	if npc_id in sheltered_npcs:
		return false

	sheltered_npcs.append(npc_id)

	# Mark NPC as helped in the siege data
	for npc_data in active_siege.get("npcs_needing_help", []):
		if npc_data.npc_id == npc_id:
			npc_data.helped = true
			break

	EventBus.npc_sheltered.emit(npc_id)
	return true


func get_npcs_needing_help() -> Array:
	if not siege_active:
		return []

	var needing_help = []
	for npc_data in active_siege.get("npcs_needing_help", []):
		if not npc_data.helped:
			needing_help.append(npc_data)
	return needing_help


func is_siege_active() -> bool:
	return siege_active


func get_siege_info() -> Dictionary:
	return active_siege


func _select_affected_npcs(count: int) -> Array:
	var all_npcs = []
	if has_node("/root/NPCDatabase"):
		all_npcs = get_node("/root/NPCDatabase").get_all_npc_ids()
	# Exclude special NPCs from being affected
	var excluded = ["void_vendor"]
	var eligible = []
	for npc_id in all_npcs:
		if npc_id not in excluded:
			eligible.append(npc_id)
	eligible.shuffle()
	return eligible.slice(0, mini(count, eligible.size()))


func _on_day_started(_day: int, _season: String):
	# Check if siege should end based on duration
	if siege_active:
		var elapsed = EventBus.current_hour - siege_start_hour
		if elapsed < 0:
			elapsed += 24
		var duration = active_siege.get("duration_hours", 6)
		if elapsed >= duration:
			end_siege()


func get_save_data() -> Dictionary:
	return {
		"siege_active": siege_active,
		"active_siege": active_siege.duplicate(true),
		"affected_npcs": affected_npcs.duplicate(),
		"sheltered_npcs": sheltered_npcs.duplicate(),
		"siege_start_hour": siege_start_hour
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("siege_active"):
		siege_active = data.siege_active
	if data.has("active_siege"):
		active_siege = data.active_siege
	if data.has("affected_npcs"):
		affected_npcs = data.affected_npcs
	if data.has("sheltered_npcs"):
		sheltered_npcs = data.sheltered_npcs
	if data.has("siege_start_hour"):
		siege_start_hour = data.siege_start_hour
