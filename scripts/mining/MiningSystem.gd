extends Node
## MiningSystem - Manages ore nodes, mining progression, and resource extraction.
## Works with the PickaxeTool to break rocks and extract ores from the world.

## Ore types and their properties
var ore_registry: Dictionary = {}

## Tracks which tiles have been mined (for respawn logic)
var mined_tiles: Dictionary = {}

## Days until mined rocks respawn
const ROCK_RESPAWN_DAYS: int = 3


func _ready():
	_register_ores()
	EventBus.day_started.connect(_on_day_started)


func _register_ores():
	_register_ore("copper_ore", "Copper Ore", 1, 0.40, 15)
	_register_ore("iron_ore", "Iron Ore", 2, 0.30, 25)
	_register_ore("gold_ore", "Gold Ore", 3, 0.15, 50)
	_register_ore("crystal_shard", "Crystal Shard", 4, 0.08, 80)


func _register_ore(id: String, display_name: String, min_pickaxe_level: int,
		drop_chance: float, sell_price: int):
	ore_registry[id] = {
		"id": id,
		"name": display_name,
		"min_pickaxe_level": min_pickaxe_level,
		"drop_chance": drop_chance,
		"sell_price": sell_price
	}


## Attempt to mine a rock at a given tile position.
## pickaxe_level determines which ores can drop.
## Returns an array of item drops.
func mine_rock(tile_pos: Vector2i, pickaxe_level: int) -> Array:
	var drops: Array = []

	# Roll for each ore type the pickaxe can handle
	for ore_id in ore_registry:
		var ore_data: Dictionary = ore_registry[ore_id]
		if pickaxe_level >= ore_data.min_pickaxe_level:
			if randf() < ore_data.drop_chance:
				drops.append({"item_id": ore_id, "quantity": 1})

	# Always drop at least stone (copper ore as base)
	if drops.is_empty():
		drops.append({"item_id": "copper_ore", "quantity": 1})

	# Track this mined tile for respawn
	mined_tiles[tile_pos] = ROCK_RESPAWN_DAYS

	# Add drops to inventory
	for drop in drops:
		InventorySystem.add_item(drop.item_id, drop.quantity)

	EventBus.rock_mined.emit(tile_pos)

	return drops


## Check if a tile has been mined and is still on cooldown.
func is_tile_mined(tile_pos: Vector2i) -> bool:
	return mined_tiles.has(tile_pos)


## Called each day to count down respawn timers.
func _on_day_started(_day: int, _season: String):
	var to_remove: Array = []
	for tile_pos in mined_tiles:
		mined_tiles[tile_pos] -= 1
		if mined_tiles[tile_pos] <= 0:
			to_remove.append(tile_pos)

	for tile_pos in to_remove:
		mined_tiles.erase(tile_pos)


## Get ore info from the registry.
func get_ore_info(ore_id: String) -> Dictionary:
	return ore_registry.get(ore_id, {})


## Save mining data.
func get_save_data() -> Dictionary:
	var tile_data: Dictionary = {}
	for tile_pos in mined_tiles:
		var key: String = str(tile_pos.x) + "," + str(tile_pos.y)
		tile_data[key] = mined_tiles[tile_pos]
	return {"mined_tiles": tile_data}


## Load mining data.
func load_save_data(data: Dictionary) -> void:
	mined_tiles.clear()
	if data.has("mined_tiles"):
		for key in data.mined_tiles:
			var parts: PackedStringArray = key.split(",")
			if parts.size() == 2:
				var tile_pos := Vector2i(int(parts[0]), int(parts[1]))
				mined_tiles[tile_pos] = data.mined_tiles[key]
