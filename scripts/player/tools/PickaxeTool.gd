class_name PickaxeTool extends ToolBase
## PickaxeTool - Breaks rocks and mines ore from stone nodes.

func _init():
	tool_name = "Pickaxe"
	tool_type = "pickaxe"
	energy_cost = 3
	use_range = 40.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)

	# Check for rock at this position on the objects layer
	var objects_layer = farm.get_node_or_null("ObjectsLayer")
	if not objects_layer:
		return false

	var source_id: int = objects_layer.get_cell_source_id(tile_pos)
	if source_id == -1:
		return false

	var atlas_coords: Vector2i = objects_layer.get_cell_atlas_coords(tile_pos)
	if _is_mineable(atlas_coords):
		objects_layer.erase_cell(tile_pos)
		# Drop ore into inventory based on chance
		var roll := randf()
		if roll < 0.4:
			InventorySystem.add_item("copper_ore", 1)
		elif roll < 0.7:
			InventorySystem.add_item("iron_ore", 1)
		else:
			# Just stone, no special ore
			pass
		return true

	return false


func _is_mineable(atlas_coords: Vector2i) -> bool:
	# Rock tiles from WorldGenerator
	var rock_tiles: Array = [
		Vector2i(12, 3),
		Vector2i(13, 3),
	]
	return atlas_coords in rock_tiles


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
