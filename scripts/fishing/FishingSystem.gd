extends Node
## FishingSystem - Manages fishing spots, fish types, and catch mechanics.
## Fish are caught by using the Fishing Rod tool near water tiles.

## Fish registry: fish_id -> fish data
var fish_registry: Dictionary = {}

## Season-based fish availability
var seasonal_fish: Dictionary = {}


func _ready():
	_register_fish()
	_setup_seasonal_fish()


func _register_fish():
	_register_fish_type("bass", "Bass", ["Spring", "Summer", "Fall"], 30, 0.30)
	_register_fish_type("trout", "Trout", ["Spring", "Fall"], 45, 0.25)
	_register_fish_type("catfish", "Catfish", ["Summer", "Fall"], 50, 0.20)
	_register_fish_type("salmon", "Salmon", ["Fall"], 75, 0.12)
	_register_fish_type("golden_fish", "Golden Fish", ["Spring", "Summer", "Fall", "Winter"], 200, 0.05)
	_register_fish_type("ice_pike", "Ice Pike", ["Winter"], 90, 0.10)
	_register_fish_type("sunfish", "Sunfish", ["Summer"], 40, 0.25)
	_register_fish_type("rift_eel", "Rift Eel", ["Spring", "Summer", "Fall", "Winter"], 150, 0.03)


func _register_fish_type(id: String, display_name: String, seasons: Array,
		sell_price: int, catch_rate: float):
	fish_registry[id] = {
		"id": id,
		"name": display_name,
		"seasons": seasons,
		"sell_price": sell_price,
		"catch_rate": catch_rate
	}


func _setup_seasonal_fish():
	seasonal_fish = {
		"Spring": ["bass", "trout", "golden_fish", "rift_eel"],
		"Summer": ["bass", "catfish", "sunfish", "golden_fish", "rift_eel"],
		"Fall": ["bass", "trout", "catfish", "salmon", "golden_fish", "rift_eel"],
		"Winter": ["ice_pike", "golden_fish", "rift_eel"]
	}


## Attempt to catch a fish based on current season.
## Returns the fish_id caught, or empty string if nothing caught.
func attempt_catch() -> String:
	var season: String = EventBus.current_season
	var available: Array = seasonal_fish.get(season, [])

	if available.is_empty():
		return ""

	# Roll for each available fish in order of rarity (rarest first)
	var sorted_fish: Array = available.duplicate()
	sorted_fish.sort_custom(_sort_by_rarity)

	for fish_id in sorted_fish:
		var fish_data: Dictionary = fish_registry.get(fish_id, {})
		var catch_rate: float = fish_data.get("catch_rate", 0.0)
		if randf() < catch_rate:
			EventBus.fish_caught.emit(fish_id)
			return fish_id

	return ""


func _sort_by_rarity(a: String, b: String) -> bool:
	var rate_a: float = fish_registry.get(a, {}).get("catch_rate", 1.0)
	var rate_b: float = fish_registry.get(b, {}).get("catch_rate", 1.0)
	return rate_a < rate_b


## Get fish info from the registry.
func get_fish_info(fish_id: String) -> Dictionary:
	return fish_registry.get(fish_id, {})


## Get all fish available in the current season.
func get_current_season_fish() -> Array:
	var season: String = EventBus.current_season
	return seasonal_fish.get(season, [])


## Save fishing data.
func get_save_data() -> Dictionary:
	return {}


## Load fishing data.
func load_save_data(_data: Dictionary) -> void:
	pass
