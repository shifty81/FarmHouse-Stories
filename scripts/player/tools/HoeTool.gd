class_name HoeTool extends ToolBase
## HoeTool - Tills soil to prepare it for planting crops.

func _init():
	tool_name = "Hoe"
	tool_type = "hoe"
	energy_cost = 2
	use_range = 40.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)

	if farm.is_plantable(tile_pos):
		# Tile is already tilled/plantable
		return false

	# Till the soil at this position
	if farm.till_soil(tile_pos):
		EventBus.crop_planted.emit(tile_pos, "tilled")
		return true

	return false


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
