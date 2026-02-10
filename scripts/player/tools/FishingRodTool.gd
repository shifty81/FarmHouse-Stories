class_name FishingRodTool extends ToolBase
## FishingRodTool - Casts a line to catch fish when near water.

func _init():
	tool_name = "Fishing Rod"
	tool_type = "fishing_rod"
	energy_cost = 2
	use_range = 48.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)

	# Check if the target tile is water
	var ground_layer = farm.get_node_or_null("GroundLayer")
	if not ground_layer:
		return false

	var source_id: int = ground_layer.get_cell_source_id(tile_pos)
	if source_id == -1:
		return false

	var atlas_coords: Vector2i = ground_layer.get_cell_atlas_coords(tile_pos)
	if _is_water_tile(atlas_coords):
		# Attempt to catch a fish
		var fish_id: String = _roll_fish_catch()
		if fish_id != "":
			InventorySystem.add_item(fish_id, 1)
			EventBus.special_item_obtained.emit(fish_id)
		return true

	return false


func _is_water_tile(atlas_coords: Vector2i) -> bool:
	var water_tiles: Array = [
		Vector2i(2, 9), Vector2i(3, 9), Vector2i(15, 9),
		Vector2i(2, 10), Vector2i(19, 0), Vector2i(15, 10),
		Vector2i(2, 6), Vector2i(3, 6), Vector2i(16, 8),
	]
	return atlas_coords in water_tiles


func _roll_fish_catch() -> String:
	var roll := randf()
	if roll < 0.05:
		# Nothing caught
		return ""
	elif roll < 0.35:
		return "bass"
	elif roll < 0.60:
		return "trout"
	elif roll < 0.80:
		return "catfish"
	elif roll < 0.92:
		return "salmon"
	else:
		return "golden_fish"


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
