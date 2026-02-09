extends Node2D
## Crop - Represents a single planted crop in the game world.

var crop_data: CropData
var current_day: int = 0
var is_watered: bool = false
var current_stage: int = 0

@onready var sprite = $Sprite2D

signal harvest_ready(crop: Node2D)


func initialize(data: CropData):
	crop_data = data
	_update_visual()


func water():
	if not is_watered:
		is_watered = true
		sprite.modulate = Color(0.8, 0.8, 1.0)


func advance_day():
	if is_watered:
		current_day += 1
		is_watered = false
		sprite.modulate = Color.WHITE

		var days_per_stage = float(crop_data.growth_days) / crop_data.growth_stages
		var new_stage = int(current_day / days_per_stage)

		if new_stage != current_stage and new_stage <= crop_data.growth_stages:
			current_stage = new_stage
			_update_visual()

			if is_mature():
				harvest_ready.emit(self)


func is_mature() -> bool:
	return current_stage >= crop_data.growth_stages


func harvest() -> Dictionary:
	if not is_mature():
		return {}

	var result = {
		"crop_name": crop_data.crop_name,
		"value": crop_data.sell_price,
		"quality": 1
	}

	if crop_data.regrows:
		current_day = crop_data.growth_days - crop_data.regrow_days
		current_stage = crop_data.growth_stages - 1
		_update_visual()
	else:
		queue_free()

	return result


func _update_visual():
	if crop_data and crop_data.stage_textures.size() > current_stage:
		sprite.texture = crop_data.stage_textures[current_stage]
