class_name ScytheTool extends ToolBase
## ScytheTool - Harvests mature crops and cuts grass. Costs no energy.

func _init():
	tool_name = "Scythe"
	tool_type = "scythe"
	energy_cost = 0
	use_range = 40.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)
	var crop_manager = farm.get_node_or_null("CropManager")

	if crop_manager and crop_manager.planted_crops.has(tile_pos):
		var result: Dictionary = crop_manager.harvest_crop(tile_pos)
		if not result.is_empty():
			# Add harvested crop to inventory
			var crop_id: String = result.get("crop_name", "")
			if crop_id != "" and InventorySystem.item_registry.has(crop_id):
				InventorySystem.add_item(crop_id, 1)
			return true

	return false


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
