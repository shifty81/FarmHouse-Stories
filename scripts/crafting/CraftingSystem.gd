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
