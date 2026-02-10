extends Node
## InventorySystem - Manages player inventory with item stacking, categories, and hotbar.
## Supports farming tools, crops, dungeon loot, crafting materials, and consumables.

const MAX_INVENTORY_SLOTS: int = 36
const MAX_HOTBAR_SLOTS: int = 9
const MAX_STACK_SIZE: int = 99

## Item categories for organization
enum ItemCategory {
	TOOL,
	CROP,
	SEED,
	MATERIAL,
	CONSUMABLE,
	LOOT,
	KEY_ITEM,
	GEAR,
	FISH
}

## Main inventory storage: Array of slot dictionaries
## Each slot: { "item_id": String, "quantity": int, "category": int, "data": Dictionary }
var slots: Array = []

## Currently selected hotbar slot index (0-8)
var selected_hotbar_slot: int = 0

## Item registry: static data for all known items
var item_registry: Dictionary = {}


func _ready():
	_initialize_slots()
	_register_default_items()
	_add_starter_items()


func _initialize_slots():
	slots.clear()
	for i in range(MAX_INVENTORY_SLOTS):
		slots.append(null)


func _register_default_items():
	# Farming tools
	_register_item("hoe", "Hoe", ItemCategory.TOOL, {
		"description": "Tills soil for planting crops.",
		"stackable": false, "energy_cost": 2
	})
	_register_item("watering_can", "Watering Can", ItemCategory.TOOL, {
		"description": "Waters planted crops.",
		"stackable": false, "energy_cost": 1
	})
	_register_item("axe", "Axe", ItemCategory.TOOL, {
		"description": "Chops trees and stumps.",
		"stackable": false, "energy_cost": 3
	})
	_register_item("pickaxe", "Pickaxe", ItemCategory.TOOL, {
		"description": "Breaks rocks and mines ore.",
		"stackable": false, "energy_cost": 3
	})
	_register_item("scythe", "Scythe", ItemCategory.TOOL, {
		"description": "Harvests mature crops and cuts grass.",
		"stackable": false, "energy_cost": 0
	})
	_register_item("fishing_rod", "Fishing Rod", ItemCategory.TOOL, {
		"description": "Cast a line to catch fish.",
		"stackable": false, "energy_cost": 2
	})

	# Seeds
	_register_item("turnip_seeds", "Turnip Seeds", ItemCategory.SEED, {
		"description": "Plant in spring. Grows in 4 days.",
		"stackable": true, "crop_id": "turnip", "season": "Spring", "buy_price": 20
	})
	_register_item("potato_seeds", "Potato Seeds", ItemCategory.SEED, {
		"description": "Plant in spring. Grows in 6 days.",
		"stackable": true, "crop_id": "potato", "season": "Spring", "buy_price": 50
	})
	_register_item("tomato_seeds", "Tomato Seeds", ItemCategory.SEED, {
		"description": "Plant in summer. Regrows every 3 days.",
		"stackable": true, "crop_id": "tomato", "season": "Summer", "buy_price": 50
	})
	_register_item("pumpkin_seeds", "Pumpkin Seeds", ItemCategory.SEED, {
		"description": "Plant in fall. Grows in 13 days.",
		"stackable": true, "crop_id": "pumpkin", "season": "Fall", "buy_price": 100
	})

	# Harvested crops
	_register_item("turnip", "Turnip", ItemCategory.CROP, {
		"description": "A hearty root vegetable.", "stackable": true, "sell_price": 60
	})
	_register_item("potato", "Potato", ItemCategory.CROP, {
		"description": "A starchy staple crop.", "stackable": true, "sell_price": 80
	})
	_register_item("tomato", "Tomato", ItemCategory.CROP, {
		"description": "A juicy red fruit.", "stackable": true, "sell_price": 60
	})
	_register_item("pumpkin", "Pumpkin", ItemCategory.CROP, {
		"description": "A large orange gourd.", "stackable": true, "sell_price": 320

	})

	# Dungeon materials
	_register_item("copper_ore", "Copper Ore", ItemCategory.MATERIAL, {
		"description": "Raw copper ore from the mines.", "stackable": true, "sell_price": 15
	})
	_register_item("iron_ore", "Iron Ore", ItemCategory.MATERIAL, {
		"description": "Raw iron ore from deep underground.", "stackable": true, "sell_price": 25
	})
	_register_item("hardwood", "Hardwood", ItemCategory.MATERIAL, {
		"description": "Dense, durable wood from old trees.", "stackable": true, "sell_price": 30
	})
	_register_item("chronos_shard", "Chronos Shard", ItemCategory.KEY_ITEM, {
		"description": "A shimmering shard that unlocks Mythic Rift access.",
		"stackable": true, "sell_price": 0
	})
	_register_item("ethereal_token", "Ethereal Token", ItemCategory.KEY_ITEM, {
		"description": "Currency for upgrading dungeon gear at the Void Anchor.",
		"stackable": true, "sell_price": 0
	})

	# Consumables
	_register_item("health_potion", "Health Potion", ItemCategory.CONSUMABLE, {
		"description": "Restores 30 HP.", "stackable": true,
		"effect_type": "heal_hp", "effect_value": 30, "buy_price": 50
	})
	_register_item("energy_tonic", "Energy Tonic", ItemCategory.CONSUMABLE, {
		"description": "Restores 25 energy.", "stackable": true,
		"effect_type": "restore_energy", "effect_value": 25, "buy_price": 40
	})
	_register_item("medicinal_herb", "Medicinal Herb", ItemCategory.MATERIAL, {
		"description": "A rare herb used in healing remedies.",
		"stackable": true, "sell_price": 20
	})

	# Dungeon loot
	_register_item("echo_crystal", "Echo Crystal", ItemCategory.LOOT, {
		"description": "A resonating crystal from Echo Caverns.",
		"stackable": true, "sell_price": 75
	})
	_register_item("void_fragment", "Void Fragment", ItemCategory.LOOT, {
		"description": "A dangerous shard of pure void energy.",
		"stackable": true, "sell_price": 150
	})

	# Fish
	_register_item("bass", "Bass", ItemCategory.FISH, {
		"description": "A common freshwater fish.", "stackable": true, "sell_price": 30
	})
	_register_item("trout", "Trout", ItemCategory.FISH, {
		"description": "A speckled stream fish.", "stackable": true, "sell_price": 45
	})
	_register_item("catfish", "Catfish", ItemCategory.FISH, {
		"description": "A whiskered bottom-feeder.", "stackable": true, "sell_price": 50
	})
	_register_item("salmon", "Salmon", ItemCategory.FISH, {
		"description": "A prized pink-fleshed fish.", "stackable": true, "sell_price": 75
	})
	_register_item("golden_fish", "Golden Fish", ItemCategory.FISH, {
		"description": "A rare shimmering fish worth a fortune.", "stackable": true, "sell_price": 200
	})
	_register_item("ice_pike", "Ice Pike", ItemCategory.FISH, {
		"description": "A cold-water predator found only in winter.", "stackable": true, "sell_price": 90
	})
	_register_item("sunfish", "Sunfish", ItemCategory.FISH, {
		"description": "A bright, warm-water fish.", "stackable": true, "sell_price": 40
	})
	_register_item("rift_eel", "Rift Eel", ItemCategory.FISH, {
		"description": "An eerie eel infused with rift energy.", "stackable": true, "sell_price": 150
	})

	# Refined materials
	_register_item("copper_bar", "Copper Bar", ItemCategory.MATERIAL, {
		"description": "A refined bar of copper.", "stackable": true, "sell_price": 60
	})
	_register_item("iron_bar", "Iron Bar", ItemCategory.MATERIAL, {
		"description": "A refined bar of iron.", "stackable": true, "sell_price": 100
	})
	_register_item("gold_ore", "Gold Ore", ItemCategory.MATERIAL, {
		"description": "Raw gold ore from deep underground.", "stackable": true, "sell_price": 50
	})
	_register_item("crystal_shard", "Crystal Shard", ItemCategory.MATERIAL, {
		"description": "A glowing shard from crystal deposits.", "stackable": true, "sell_price": 80
	})

	# Crafted consumables
	_register_item("turnip_soup", "Turnip Soup", ItemCategory.CONSUMABLE, {
		"description": "A warm bowl of turnip soup. Restores 20 energy.",
		"stackable": true, "effect_type": "restore_energy", "effect_value": 20, "sell_price": 50
	})
	_register_item("veggie_stew", "Veggie Stew", ItemCategory.CONSUMABLE, {
		"description": "A hearty vegetable stew. Restores 40 energy.",
		"stackable": true, "effect_type": "restore_energy", "effect_value": 40, "sell_price": 120
	})
	_register_item("pumpkin_pie", "Pumpkin Pie", ItemCategory.CONSUMABLE, {
		"description": "A sweet pumpkin pie. Restores 50 HP.",
		"stackable": true, "effect_type": "heal_hp", "effect_value": 50, "sell_price": 200
	})

	# Crafted special items
	_register_item("echo_lantern", "Echo Lantern", ItemCategory.KEY_ITEM, {
		"description": "A lantern that reveals hidden paths in Echo Caverns.",
		"stackable": false, "sell_price": 0
	})
	_register_item("void_charm", "Void Charm", ItemCategory.KEY_ITEM, {
		"description": "A charm that provides protection in the Void Fortress.",
		"stackable": false, "sell_price": 0
	})


func _register_item(id: String, display_name: String, category: ItemCategory, data: Dictionary):
	item_registry[id] = {
		"id": id,
		"name": display_name,
		"category": category,
		"data": data
	}


func _add_starter_items():
	add_item("hoe", 1)
	add_item("watering_can", 1)
	add_item("axe", 1)
	add_item("pickaxe", 1)
	add_item("scythe", 1)
	add_item("turnip_seeds", 15)


## Add an item to inventory. Returns the quantity actually added.
func add_item(item_id: String, quantity: int = 1) -> int:
	if not item_registry.has(item_id):
		print("Unknown item: ", item_id)
		return 0

	var item_info = item_registry[item_id]
	var is_stackable = item_info.data.get("stackable", true)
	var remaining = quantity

	# Try to stack onto existing slots first
	if is_stackable:
		for i in range(slots.size()):
			if remaining <= 0:
				break
			if slots[i] and slots[i].item_id == item_id:
				var space = MAX_STACK_SIZE - slots[i].quantity
				var to_add = mini(remaining, space)
				if to_add > 0:
					slots[i].quantity += to_add
					remaining -= to_add

	# Place remainder in empty slots
	for i in range(slots.size()):
		if remaining <= 0:
			break
		if slots[i] == null:
			var stack_amount = mini(remaining, MAX_STACK_SIZE) if is_stackable else 1
			slots[i] = {
				"item_id": item_id,
				"quantity": stack_amount,
				"category": item_info.category,
				"data": item_info.data.duplicate()
			}
			remaining -= stack_amount

	var added: int = quantity - remaining
	if added > 0:
		EventBus.inventory_item_added.emit(item_id, added)
	return added


## Remove a quantity of an item. Returns how many were actually removed.
func remove_item(item_id: String, quantity: int = 1) -> int:
	var remaining = quantity

	for i in range(slots.size() - 1, -1, -1):
		if remaining <= 0:
			break
		if slots[i] and slots[i].item_id == item_id:
			var to_remove = mini(remaining, slots[i].quantity)
			slots[i].quantity -= to_remove
			remaining -= to_remove
			if slots[i].quantity <= 0:
				slots[i] = null

	return quantity - remaining


## Check if the player has at least a given quantity of an item.
func has_item(item_id: String, quantity: int = 1) -> bool:
	var count = get_item_count(item_id)
	return count >= quantity


## Count total quantity of an item across all slots.
func get_item_count(item_id: String) -> int:
	var count = 0
	for slot in slots:
		if slot and slot.item_id == item_id:
			count += slot.quantity
	return count


## Get the item in a specific slot index.
func get_slot(index: int) -> Variant:
	if index < 0 or index >= slots.size():
		return null
	return slots[index]


## Get the currently selected hotbar item.
func get_selected_item() -> Variant:
	return get_slot(selected_hotbar_slot)


## Select a hotbar slot (0 to MAX_HOTBAR_SLOTS - 1).
func select_hotbar_slot(index: int):
	if index >= 0 and index < MAX_HOTBAR_SLOTS:
		selected_hotbar_slot = index


## Swap two inventory slots.
func swap_slots(index_a: int, index_b: int):
	if index_a < 0 or index_a >= slots.size():
		return
	if index_b < 0 or index_b >= slots.size():
		return
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp


## Use a consumable item from inventory.
func use_item(item_id: String) -> bool:
	if not has_item(item_id):
		return false

	var item_info = item_registry.get(item_id, {})
	var data = item_info.get("data", {})

	if data.get("effect_type", "") == "heal_hp":
		# HP healing will be used once combat HP is tracked
		remove_item(item_id, 1)
		return true
	elif data.get("effect_type", "") == "restore_energy":
		var restore = data.get("effect_value", 0)
		EventBus.player_energy = mini(EventBus.player_energy + restore, EventBus.player_max_energy)
		EventBus.player_energy_changed.emit(EventBus.player_energy, EventBus.player_max_energy)
		remove_item(item_id, 1)
		return true

	return false


## Get item info from the registry.
func get_item_info(item_id: String) -> Dictionary:
	return item_registry.get(item_id, {})


## Get all non-empty inventory slots with their indices.
func get_all_items() -> Array:
	var items = []
	for i in range(slots.size()):
		if slots[i]:
			items.append({"index": i, "slot": slots[i]})
	return items


## Save inventory data for the save system.
func get_save_data() -> Dictionary:
	var slot_data = []
	for slot in slots:
		if slot:
			slot_data.append({
				"item_id": slot.item_id,
				"quantity": slot.quantity
			})
		else:
			slot_data.append(null)

	return {
		"slots": slot_data,
		"selected_hotbar_slot": selected_hotbar_slot
	}


## Load inventory data from a save file.
func load_save_data(data: Dictionary) -> void:
	_initialize_slots()

	if data.has("selected_hotbar_slot"):
		selected_hotbar_slot = data.selected_hotbar_slot

	if data.has("slots"):
		for i in range(mini(data.slots.size(), slots.size())):
			var slot_data = data.slots[i]
			if slot_data and slot_data is Dictionary:
				var item_id = slot_data.get("item_id", "")
				if item_registry.has(item_id):
					var item_info = item_registry[item_id]
					slots[i] = {
						"item_id": item_id,
						"quantity": slot_data.get("quantity", 1),
						"category": item_info.category,
						"data": item_info.data.duplicate()
					}
