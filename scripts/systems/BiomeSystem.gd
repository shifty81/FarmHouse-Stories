extends Node
## BiomeSystem - Defines biome types, their properties, and adjacency rules.
## Inspired by Necesse's layered biome system with rule-based adjacency checks,
## and Core Keeper's radial zone layout where biomes are placed in concentric
## rings radiating outward from a central point.
##
## Each biome has terrain types, vegetation density, resource distribution,
## and rules about which biomes can appear next to each other.

## Zone ring distances from the world center (Core Keeper style).
## Inner rings are safer; outer rings are more dangerous.
const ZONE_RINGS = {
	"center":   {"min_dist": 0,   "max_dist": 30},
	"inner":    {"min_dist": 30,  "max_dist": 80},
	"middle":   {"min_dist": 80,  "max_dist": 150},
	"outer":    {"min_dist": 150, "max_dist": 250},
	"frontier": {"min_dist": 250, "max_dist": 999}
}

## Biome definitions with terrain, vegetation, resources, and placement rules
const BIOMES = {
	"meadow": {
		"id": "meadow",
		"name": "Verdant Meadow",
		"description": "Lush grasslands with wildflowers and gentle hills.",
		"zone": "center",
		"difficulty": 0,
		"ground_tiles": ["grass", "grass_light"],
		"vegetation": ["flower", "bush", "tall_grass"],
		"resources": ["fiber", "herb", "berry"],
		"vegetation_density": 0.15,
		"resource_density": 0.05,
		"tree_density": 0.03,
		"height_range": [0.35, 0.65],
		"moisture_range": [0.3, 0.7],
		"temperature_range": [0.3, 0.7],
		"color_hint": Color(0.4, 0.75, 0.3)
	},
	"forest": {
		"id": "forest",
		"name": "Whispering Woods",
		"description": "Dense forest with towering trees and hidden paths.",
		"zone": "inner",
		"difficulty": 1,
		"ground_tiles": ["grass", "forest_floor"],
		"vegetation": ["bush", "mushroom", "fern"],
		"resources": ["wood", "mushroom", "sap", "acorn"],
		"vegetation_density": 0.25,
		"resource_density": 0.08,
		"tree_density": 0.35,
		"height_range": [0.35, 0.7],
		"moisture_range": [0.45, 0.85],
		"temperature_range": [0.25, 0.65],
		"color_hint": Color(0.2, 0.5, 0.15)
	},
	"plains": {
		"id": "plains",
		"name": "Golden Plains",
		"description": "Open grasslands with scattered rocks and grazing areas.",
		"zone": "inner",
		"difficulty": 1,
		"ground_tiles": ["grass", "dirt"],
		"vegetation": ["tall_grass", "flower"],
		"resources": ["fiber", "stone", "clay"],
		"vegetation_density": 0.10,
		"resource_density": 0.04,
		"tree_density": 0.02,
		"height_range": [0.40, 0.60],
		"moisture_range": [0.2, 0.5],
		"temperature_range": [0.4, 0.8],
		"color_hint": Color(0.7, 0.65, 0.3)
	},
	"swamp": {
		"id": "swamp",
		"name": "Murkmire Swamp",
		"description": "Boggy wetlands shrouded in mist with treacherous footing.",
		"zone": "middle",
		"difficulty": 2,
		"ground_tiles": ["marsh", "dirt"],
		"vegetation": ["cattail", "moss", "vine"],
		"resources": ["slime", "swamp_herb", "peat"],
		"vegetation_density": 0.20,
		"resource_density": 0.07,
		"tree_density": 0.12,
		"height_range": [0.15, 0.40],
		"moisture_range": [0.7, 1.0],
		"temperature_range": [0.3, 0.6],
		"color_hint": Color(0.3, 0.45, 0.25)
	},
	"desert": {
		"id": "desert",
		"name": "Sun-Scorched Dunes",
		"description": "Arid sands with cacti and ancient ruins half-buried by wind.",
		"zone": "middle",
		"difficulty": 2,
		"ground_tiles": ["sand", "dirt"],
		"vegetation": ["cactus", "dead_bush", "tumbleweed"],
		"resources": ["sand_crystal", "dry_bone", "cactus_fruit"],
		"vegetation_density": 0.05,
		"resource_density": 0.04,
		"tree_density": 0.0,
		"height_range": [0.30, 0.65],
		"moisture_range": [0.0, 0.2],
		"temperature_range": [0.7, 1.0],
		"color_hint": Color(0.85, 0.75, 0.45)
	},
	"tundra": {
		"id": "tundra",
		"name": "Frostveil Tundra",
		"description": "Frozen expanse where icy winds howl across barren snowfields.",
		"zone": "middle",
		"difficulty": 2,
		"ground_tiles": ["snow", "ice"],
		"vegetation": ["snow_bush", "icicle"],
		"resources": ["ice_shard", "frozen_herb", "arctic_stone"],
		"vegetation_density": 0.04,
		"resource_density": 0.05,
		"tree_density": 0.01,
		"height_range": [0.30, 0.70],
		"moisture_range": [0.2, 0.6],
		"temperature_range": [0.0, 0.25],
		"color_hint": Color(0.8, 0.85, 0.95)
	},
	"volcanic": {
		"id": "volcanic",
		"name": "Ember Wastes",
		"description": "Smouldering volcanic terrain with lava flows and obsidian outcrops.",
		"zone": "outer",
		"difficulty": 3,
		"ground_tiles": ["cave_floor", "stone"],
		"vegetation": ["ember_moss", "fire_bloom"],
		"resources": ["obsidian", "fire_crystal", "molten_ore", "sulphur"],
		"vegetation_density": 0.03,
		"resource_density": 0.10,
		"tree_density": 0.0,
		"height_range": [0.45, 0.85],
		"moisture_range": [0.0, 0.15],
		"temperature_range": [0.85, 1.0],
		"color_hint": Color(0.6, 0.2, 0.1)
	},
	"rift_wastes": {
		"id": "rift_wastes",
		"name": "Rift-Touched Wastes",
		"description": "Reality warps at the edge of the world where Rift energy bleeds through.",
		"zone": "outer",
		"difficulty": 4,
		"ground_tiles": ["rift_touched", "void"],
		"vegetation": ["rift_tendril", "void_bloom"],
		"resources": ["void_shard", "rift_crystal", "chrono_dust", "ethereal_fiber"],
		"vegetation_density": 0.08,
		"resource_density": 0.12,
		"tree_density": 0.0,
		"height_range": [0.20, 0.80],
		"moisture_range": [0.0, 1.0],
		"temperature_range": [0.0, 1.0],
		"color_hint": Color(0.4, 0.1, 0.55)
	},
	"crystal_caves": {
		"id": "crystal_caves",
		"name": "Crystal Hollows",
		"description": "Underground caverns lined with luminescent crystals.",
		"zone": "middle",
		"difficulty": 3,
		"ground_tiles": ["cave_floor", "stone"],
		"vegetation": ["glowing_mushroom", "crystal_vine"],
		"resources": ["crystal_shard", "rare_gem", "luminous_moss"],
		"vegetation_density": 0.10,
		"resource_density": 0.15,
		"tree_density": 0.0,
		"height_range": [0.0, 0.25],
		"moisture_range": [0.4, 0.8],
		"temperature_range": [0.2, 0.5],
		"color_hint": Color(0.3, 0.6, 0.8)
	},
	"ancient_ruins": {
		"id": "ancient_ruins",
		"name": "Forgotten Ruins",
		"description": "Crumbling remnants of an ancient civilization, overgrown and mysterious.",
		"zone": "outer",
		"difficulty": 3,
		"ground_tiles": ["stone", "dirt"],
		"vegetation": ["vine", "moss", "old_tree"],
		"resources": ["ancient_coin", "rune_stone", "artifact_shard"],
		"vegetation_density": 0.12,
		"resource_density": 0.08,
		"tree_density": 0.05,
		"height_range": [0.30, 0.60],
		"moisture_range": [0.3, 0.7],
		"temperature_range": [0.3, 0.6],
		"color_hint": Color(0.5, 0.45, 0.35)
	}
}

## Adjacency rules: which biomes may border each other (Necesse style).
## If a biome is not in the allowed neighbors list, a transition biome is placed.
const ADJACENCY_RULES = {
	"meadow": ["forest", "plains", "swamp"],
	"forest": ["meadow", "plains", "swamp", "crystal_caves"],
	"plains": ["meadow", "forest", "desert", "tundra"],
	"swamp": ["meadow", "forest", "crystal_caves"],
	"desert": ["plains", "volcanic", "ancient_ruins"],
	"tundra": ["plains", "crystal_caves"],
	"volcanic": ["desert", "rift_wastes", "ancient_ruins"],
	"rift_wastes": ["volcanic", "ancient_ruins"],
	"crystal_caves": ["forest", "swamp", "tundra"],
	"ancient_ruins": ["desert", "volcanic", "rift_wastes"]
}

## Points of interest that can spawn within each biome
const BIOME_STRUCTURES = {
	"meadow": ["farm_plot", "well", "signpost"],
	"forest": ["woodcutter_camp", "hidden_grove", "beehive"],
	"plains": ["windmill", "stone_circle", "camp_site"],
	"swamp": ["witch_hut", "sunken_chest", "fog_gate"],
	"desert": ["oasis", "buried_temple", "sand_pit"],
	"tundra": ["ice_shrine", "frozen_lake", "shelter"],
	"volcanic": ["forge_ruin", "lava_bridge", "obsidian_pillar"],
	"rift_wastes": ["void_anchor", "rift_portal", "chrono_well"],
	"crystal_caves": ["crystal_fountain", "gem_deposit", "echo_chamber"],
	"ancient_ruins": ["library_remains", "guardian_statue", "sealed_vault"]
}


func _ready() -> void:
	pass


func get_biome(biome_id: String) -> Dictionary:
	## Returns the full biome definition for the given ID.
	return BIOMES.get(biome_id, {})


func get_all_biome_ids() -> Array:
	## Returns all registered biome IDs.
	return BIOMES.keys()


func get_biomes_for_zone(zone: String) -> Array:
	## Returns all biome IDs assigned to the given zone ring.
	var result: Array = []
	for biome_id: String in BIOMES:
		if BIOMES[biome_id].zone == zone:
			result.append(biome_id)
	return result


func can_be_adjacent(biome_a: String, biome_b: String) -> bool:
	## Checks if two biomes are allowed to be neighbors based on adjacency rules.
	if not ADJACENCY_RULES.has(biome_a):
		return true
	return biome_b in ADJACENCY_RULES[biome_a]


func get_allowed_neighbors(biome_id: String) -> Array:
	## Returns the list of biomes that may border the given biome.
	return ADJACENCY_RULES.get(biome_id, [])


func get_structures_for_biome(biome_id: String) -> Array:
	## Returns possible point-of-interest structures for this biome.
	return BIOME_STRUCTURES.get(biome_id, [])


func determine_biome(height: float, moisture: float, temperature: float,
		distance_from_center: float) -> String:
	## Determines which biome should exist at a position based on noise values
	## and distance from world center (Core Keeper radial zone approach).
	## Returns the biome_id that best matches the given parameters.

	# Determine zone ring based on distance (Core Keeper style)
	var zone := _get_zone_for_distance(distance_from_center)

	# Get candidate biomes for this zone
	var candidates: Array = get_biomes_for_zone(zone)
	if candidates.is_empty():
		return "meadow"

	# Score each candidate by how well it matches the noise values
	var best_biome: String = candidates[0]
	var best_score: float = -1.0

	for biome_id: String in candidates:
		var biome: Dictionary = BIOMES[biome_id]
		var score := _score_biome_match(biome, height, moisture, temperature)
		if score > best_score:
			best_score = score
			best_biome = biome_id

	return best_biome


func _get_zone_for_distance(distance: float) -> String:
	## Maps a distance from center to a zone ring name.
	for zone_name: String in ZONE_RINGS:
		var ring: Dictionary = ZONE_RINGS[zone_name]
		if distance >= ring.min_dist and distance < ring.max_dist:
			return zone_name
	return "frontier"


func _score_biome_match(biome: Dictionary, height: float,
		moisture: float, temperature: float) -> float:
	## Scores how well a biome matches the given noise parameters.
	## Returns a value where higher means a better match.
	var h_range: Array = biome.get("height_range", [0.0, 1.0])
	var m_range: Array = biome.get("moisture_range", [0.0, 1.0])
	var t_range: Array = biome.get("temperature_range", [0.0, 1.0])

	var h_score := _range_score(height, h_range[0], h_range[1])
	var m_score := _range_score(moisture, m_range[0], m_range[1])
	var t_score := _range_score(temperature, t_range[0], t_range[1])

	return h_score * m_score * t_score


func _range_score(value: float, range_min: float, range_max: float) -> float:
	## Scores how well a value fits within a range. Returns 1.0 for perfect fit,
	## decreasing towards 0.0 as value deviates from range.
	if value >= range_min and value <= range_max:
		return 1.0
	if value < range_min:
		return maxf(0.0, 1.0 - (range_min - value) * 4.0)
	return maxf(0.0, 1.0 - (value - range_max) * 4.0)
