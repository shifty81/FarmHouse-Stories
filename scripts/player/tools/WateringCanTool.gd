class_name WateringCanTool extends ToolBase
## WateringCanTool - Waters planted crops to help them grow.

func _init():
	tool_name = "Watering Can"
	tool_type = "watering_can"
	energy_cost = 1
	use_range = 40.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)
	var crop_manager = farm.get_node_or_null("CropManager")

	if crop_manager and crop_manager.planted_crops.has(tile_pos):
		crop_manager.water_crop(tile_pos)
		return true

	return false


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
