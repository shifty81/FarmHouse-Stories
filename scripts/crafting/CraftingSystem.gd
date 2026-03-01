extends Node
## CraftingSystem - Manages crafting recipes and artisan goods production.
## Recipes consume materials from inventory and produce new items.

## Recipe dictionary: recipe_id -> recipe data
var recipes: Dictionary = {}


func _ready():
	_register_recipes()


func _register_recipes():
	# Cooking / consumables
	_register_recipe("turnip_soup", "Turnip Soup", [
		{"item_id": "turnip", "quantity": 2}
	], "turnip_soup", 1, 2.0)

	_register_recipe("veggie_stew", "Veggie Stew", [
		{"item_id": "potato", "quantity": 1},
		{"item_id": "tomato", "quantity": 1},
		{"item_id": "turnip", "quantity": 1}
	], "veggie_stew", 1, 3.0)

	_register_recipe("pumpkin_pie", "Pumpkin Pie", [
		{"item_id": "pumpkin", "quantity": 1}
	], "pumpkin_pie", 1, 4.0)

	# Material refinement
	_register_recipe("copper_bar", "Copper Bar", [
		{"item_id": "copper_ore", "quantity": 5}
	], "copper_bar", 1, 5.0)

	_register_recipe("iron_bar", "Iron Bar", [
		{"item_id": "iron_ore", "quantity": 5}
	], "iron_bar", 1, 5.0)

	# Artisan goods
	_register_recipe("herbal_remedy", "Herbal Remedy", [
		{"item_id": "medicinal_herb", "quantity": 3}
	], "health_potion", 2, 3.0)

	_register_recipe("energy_brew", "Energy Brew", [
		{"item_id": "medicinal_herb", "quantity": 2},
		{"item_id": "turnip", "quantity": 1}
	], "energy_tonic", 2, 3.0)

	_register_recipe("echo_lantern", "Echo Lantern", [
		{"item_id": "echo_crystal", "quantity": 2},
		{"item_id": "copper_bar", "quantity": 1}
	], "echo_lantern", 1, 6.0)

	_register_recipe("void_charm", "Void Charm", [
		{"item_id": "void_fragment", "quantity": 2},
		{"item_id": "iron_bar", "quantity": 1}
	], "void_charm", 1, 8.0)

	# Advanced cooking
	_register_recipe("strawberry_jam", "Strawberry Jam", [
		{"item_id": "strawberry", "quantity": 3}
	], "strawberry_jam", 2, 2.0)

	_register_recipe("melon_smoothie", "Melon Smoothie", [
		{"item_id": "melon", "quantity": 1}
	], "melon_smoothie", 1, 1.5)

	_register_recipe("corn_chowder", "Corn Chowder", [
		{"item_id": "corn", "quantity": 2},
		{"item_id": "potato", "quantity": 1}
	], "corn_chowder", 1, 3.0)

	_register_recipe("mega_health_potion", "Mega Health Potion", [
		{"item_id": "health_potion", "quantity": 2},
		{"item_id": "medicinal_herb", "quantity": 2},
		{"item_id": "moonstone", "quantity": 1}
	], "mega_health_potion", 1, 5.0)

	_register_recipe("stamina_elixir", "Stamina Elixir", [
		{"item_id": "energy_tonic", "quantity": 2},
		{"item_id": "medicinal_herb", "quantity": 3}
	], "stamina_elixir", 1, 5.0)

	_register_recipe("fire_resist_potion", "Fire Resistance Potion", [
		{"item_id": "health_potion", "quantity": 1},
		{"item_id": "ruby", "quantity": 1}
	], "fire_resist_potion", 1, 4.0)

	_register_recipe("frost_shield_potion", "Frost Shield Potion", [
		{"item_id": "health_potion", "quantity": 1},
		{"item_id": "sapphire", "quantity": 1}
	], "frost_shield_potion", 1, 4.0)

	# Material refinement (additional)
	_register_recipe("gold_bar", "Gold Bar", [
		{"item_id": "gold_ore", "quantity": 5}
	], "gold_bar", 1, 6.0)

	_register_recipe("mithril_bar", "Mithril Bar", [
		{"item_id": "mithril_ore", "quantity": 5}
	], "mithril_bar", 1, 8.0)

	_register_recipe("adamantite_bar", "Adamantite Bar", [
		{"item_id": "adamantite_ore", "quantity": 5}
	], "adamantite_bar", 1, 10.0)

	# Gear crafting
	_register_recipe("iron_helm", "Iron Helm", [
		{"item_id": "iron_bar", "quantity": 3}
	], "iron_helm", 1, 6.0)

	_register_recipe("chain_leggings", "Chain Leggings", [
		{"item_id": "iron_bar", "quantity": 4}
	], "chain_leggings", 1, 7.0)

	_register_recipe("echo_pendant", "Echo Pendant", [
		{"item_id": "echo_crystal", "quantity": 3},
		{"item_id": "gold_bar", "quantity": 1}
	], "echo_pendant", 1, 8.0)

	_register_recipe("mithril_armor", "Mithril Armor", [
		{"item_id": "mithril_bar", "quantity": 5},
		{"item_id": "moonstone", "quantity": 2}
	], "mithril_armor", 1, 12.0)

	_register_recipe("mithril_helm", "Mithril Helm", [
		{"item_id": "mithril_bar", "quantity": 3},
		{"item_id": "moonstone", "quantity": 1}
	], "mithril_helm", 1, 10.0)

	_register_recipe("adamantite_armor", "Adamantite Armor", [
		{"item_id": "adamantite_bar", "quantity": 5},
		{"item_id": "ruby", "quantity": 1},
		{"item_id": "sapphire", "quantity": 1}
	], "adamantite_armor", 1, 15.0)

	_register_recipe("void_cloak", "Void Cloak", [
		{"item_id": "void_fragment", "quantity": 4},
		{"item_id": "mithril_bar", "quantity": 2},
		{"item_id": "emerald", "quantity": 1}
	], "void_cloak", 1, 14.0)

	# Bait crafting
	_register_recipe("quality_bait_craft", "Quality Bait", [
		{"item_id": "basic_bait", "quantity": 3},
		{"item_id": "medicinal_herb", "quantity": 1}
	], "quality_bait", 5, 1.0)

	_register_recipe("rift_bait_craft", "Rift Bait", [
		{"item_id": "quality_bait", "quantity": 3},
		{"item_id": "void_fragment", "quantity": 1}
	], "rift_bait", 3, 2.0)

	# Fertilizer
	_register_recipe("fertilizer_craft", "Fertilizer", [
		{"item_id": "medicinal_herb", "quantity": 1},
		{"item_id": "copper_ore", "quantity": 2}
	], "fertilizer", 3, 1.5)


func _register_recipe(id: String, display_name: String, ingredients: Array,
		result_item_id: String, result_quantity: int, craft_time: float):
	recipes[id] = {
		"id": id,
		"name": display_name,
		"ingredients": ingredients,
		"result_item_id": result_item_id,
		"result_quantity": result_quantity,
		"craft_time": craft_time
	}


## Check if the player has all required ingredients for a recipe.
func can_craft(recipe_id: String) -> bool:
	if not recipes.has(recipe_id):
		return false

	var recipe: Dictionary = recipes[recipe_id]
	for ingredient in recipe.ingredients:
		if not InventorySystem.has_item(ingredient.item_id, ingredient.quantity):
			return false
	return true


## Craft an item: consume ingredients and produce the result.
## Returns a dictionary with crafting results, or empty on failure.
func craft(recipe_id: String) -> Dictionary:
	if not can_craft(recipe_id):
		return {}

	var recipe: Dictionary = recipes[recipe_id]

	# Consume ingredients
	for ingredient in recipe.ingredients:
		InventorySystem.remove_item(ingredient.item_id, ingredient.quantity)

	# Produce result
	var added: int = InventorySystem.add_item(recipe.result_item_id, recipe.result_quantity)

	EventBus.item_crafted.emit(recipe_id, recipe.result_item_id)

	return {
		"recipe_id": recipe_id,
		"result_item_id": recipe.result_item_id,
		"result_quantity": added,
		"craft_time": recipe.craft_time
	}


## Get all recipes the player can currently craft.
func get_available_recipes() -> Array:
	var available: Array = []
	for recipe_id in recipes:
		if can_craft(recipe_id):
			available.append(recipes[recipe_id])
	return available


## Get all recipes (for UI display).
func get_all_recipes() -> Array:
	return recipes.values()


## Get a specific recipe by ID.
func get_recipe(recipe_id: String) -> Dictionary:
	return recipes.get(recipe_id, {})


## Save crafting data.
func get_save_data() -> Dictionary:
	return {}


## Load crafting data.
func load_save_data(_data: Dictionary) -> void:
	pass
