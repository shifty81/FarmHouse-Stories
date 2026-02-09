extends Node2D
## Farm - Main farm scene managing the player's farm area.

@onready var crop_manager = $CropManager


func _ready():
	_setup_farm()
	EventBus.day_ended.connect(_on_day_ended)


func _setup_farm():
	pass


func get_tile_at_position(world_pos: Vector2) -> Vector2i:
	var plantable_tilemap = get_node_or_null("PlantableArea")
	if plantable_tilemap:
		return plantable_tilemap.local_to_map(plantable_tilemap.to_local(world_pos))
	return Vector2i.ZERO


func is_plantable(tile_pos: Vector2i) -> bool:
	var plantable_tilemap = get_node_or_null("PlantableArea")
	if plantable_tilemap:
		var tile_data = plantable_tilemap.get_cell_tile_data(tile_pos)
		return tile_data != null
	return false


func _on_day_ended():
	crop_manager.advance_all_crops()
