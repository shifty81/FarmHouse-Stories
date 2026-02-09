extends Node
## TerrainSystem - Manages terrain generation using tile definitions.
## Supports LPC (Liberated Pixel Cup) terrain tiles for expanded terrain variety.
## LPC terrain tiles are loaded from the LPC_Terrain asset pack.

## Terrain type definitions
const TERRAIN_TYPES = {
	"grass": {"id": 0, "name": "Grass", "walkable": true, "plantable": true, "source": "lpc"},
	"dirt": {"id": 1, "name": "Dirt Path", "walkable": true, "plantable": false, "source": "lpc"},
	"water": {"id": 2, "name": "Water", "walkable": false, "plantable": false, "source": "lpc"},
	"sand": {"id": 3, "name": "Sand", "walkable": true, "plantable": false, "source": "lpc"},
	"stone": {"id": 4, "name": "Stone Path", "walkable": true, "plantable": false, "source": "lpc"},
	"farmland": {"id": 5, "name": "Farmland", "walkable": true, "plantable": true, "source": "lpc"},
	"forest_floor": {"id": 6, "name": "Forest Floor", "walkable": true, "plantable": false, "source": "lpc"},
	"cave_floor": {"id": 7, "name": "Cave Floor", "walkable": true, "plantable": false, "source": "lpc"},
	"marsh": {"id": 8, "name": "Marsh", "walkable": true, "plantable": false, "source": "lpc"},
	"snow": {"id": 9, "name": "Snow", "walkable": true, "plantable": false, "source": "lpc"},
	"ice": {"id": 10, "name": "Ice", "walkable": true, "plantable": false, "source": "lpc"},
	"lava": {"id": 11, "name": "Lava", "walkable": false, "plantable": false, "source": "base"},
	"void": {"id": 12, "name": "Void Terrain", "walkable": false, "plantable": false, "source": "base"},
	"rift_touched": {"id": 13, "name": "Rift-Touched Ground", "walkable": true, "plantable": true, "source": "base"}
}

## LPC terrain tile source path
const LPC_TERRAIN_PATH = "res://LPC_Terrain.zip"

## Seasonal terrain variants (LPC tiles support seasonal look)
const SEASONAL_VARIANTS = {
	"Spring": ["grass", "dirt", "farmland", "forest_floor", "marsh"],
	"Summer": ["grass", "dirt", "sand", "farmland", "forest_floor"],
	"Fall": ["grass", "dirt", "farmland", "forest_floor", "marsh"],
	"Winter": ["snow", "ice", "stone", "cave_floor", "forest_floor"]
}

## Terrain tileset reference
var terrain_tileset: Resource = null
var lpc_tiles_loaded: bool = false


func _ready():
	_load_terrain_definitions()


func _load_terrain_definitions():
	if ResourceLoader.exists(LPC_TERRAIN_PATH):
		lpc_tiles_loaded = true


func get_terrain_type(type_id: String) -> Dictionary:
	return TERRAIN_TYPES.get(type_id, {})


func is_walkable(type_id: String) -> bool:
	var terrain = TERRAIN_TYPES.get(type_id, {})
	return terrain.get("walkable", false)


func is_plantable(type_id: String) -> bool:
	var terrain = TERRAIN_TYPES.get(type_id, {})
	return terrain.get("plantable", false)


func get_seasonal_terrains(season: String) -> Array:
	return SEASONAL_VARIANTS.get(season, SEASONAL_VARIANTS["Spring"])


func get_all_terrain_types() -> Array:
	return TERRAIN_TYPES.keys()


func get_lpc_terrain_types() -> Array:
	var lpc_types = []
	for type_id in TERRAIN_TYPES:
		if TERRAIN_TYPES[type_id].get("source", "") == "lpc":
			lpc_types.append(type_id)
	return lpc_types


func are_lpc_tiles_loaded() -> bool:
	return lpc_tiles_loaded
