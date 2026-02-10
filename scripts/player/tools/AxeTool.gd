class_name AxeTool extends ToolBase
## AxeTool - Chops trees and stumps for wood resources.

func _init():
	tool_name = "Axe"
	tool_type = "axe"
	energy_cost = 3
	use_range = 40.0


func perform_action(user: CharacterBody2D, target_position: Vector2) -> bool:
	var farm = _get_farm(user)
	if not farm:
		return false

	var tile_pos: Vector2i = farm.get_tile_at_position(target_position)

	# Check for tree/stump at this position on the objects layer
	var objects_layer = farm.get_node_or_null("ObjectsLayer")
	if not objects_layer:
		return false

	var source_id: int = objects_layer.get_cell_source_id(tile_pos)
	if source_id == -1:
		return false

	var atlas_coords: Vector2i = objects_layer.get_cell_atlas_coords(tile_pos)
	if _is_choppable(atlas_coords):
		objects_layer.erase_cell(tile_pos)
		# Drop hardwood into inventory
		InventorySystem.add_item("hardwood", 1)
		return true

	return false


func _is_choppable(atlas_coords: Vector2i) -> bool:
	# Tree tiles from WorldGenerator
	var tree_tiles: Array = [
		Vector2i(0, 11),
		Vector2i(4, 11),
		Vector2i(5, 11),
	]
	# Bush tile
	var bush_tile := Vector2i(11, 5)

	return atlas_coords in tree_tiles or atlas_coords == bush_tile


func _get_farm(user: CharacterBody2D) -> Node2D:
	var farm = user.get_parent().get_parent()
	if farm and farm.has_method("get_tile_at_position"):
		return farm
	return null
