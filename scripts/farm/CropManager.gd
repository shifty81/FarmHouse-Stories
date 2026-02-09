extends Node
## CropManager - Manages planting, watering, and harvesting crops.

var planted_crops: Dictionary = {}

const CROP_SCENE = preload("res://scenes/farm/Crop.tscn")


func plant_crop(tile_pos: Vector2i, crop_data: CropData) -> bool:
	if planted_crops.has(tile_pos):
		return false

	var crop = CROP_SCENE.instantiate()
	add_child(crop)

	var plantable_tilemap = get_parent().get_node_or_null("PlantableArea")
	if plantable_tilemap:
		var world_pos = plantable_tilemap.map_to_local(tile_pos)
		crop.position = world_pos

	crop.initialize(crop_data)
	crop.harvest_ready.connect(_on_crop_ready_to_harvest)

	planted_crops[tile_pos] = crop
	EventBus.crop_planted.emit(tile_pos, crop_data.crop_name)
	return true


func water_crop(tile_pos: Vector2i):
	if planted_crops.has(tile_pos):
		planted_crops[tile_pos].water()
		EventBus.crop_watered.emit(tile_pos)


func harvest_crop(tile_pos: Vector2i) -> Dictionary:
	if not planted_crops.has(tile_pos):
		return {}

	var crop = planted_crops[tile_pos]
	if not crop.is_mature():
		return {}

	var result = crop.harvest()

	if not crop.crop_data.regrows:
		planted_crops.erase(tile_pos)

	EventBus.crop_harvested.emit(tile_pos, result.crop_name, result.quality)
	return result


func advance_all_crops():
	for crop in planted_crops.values():
		crop.advance_day()


func _on_crop_ready_to_harvest(crop: Node2D):
	print("Crop ready to harvest at: ", crop.position)
