class_name CropData extends Resource
## CropData - Data definition for a crop type.

@export var crop_name: String = ""
@export var growth_days: int = 4
@export var valid_seasons: Array[String] = ["Spring"]
@export var sell_price: int = 35
@export var seed_price: int = 20
@export var regrows: bool = false
@export var regrow_days: int = 0
@export_range(0, 4) var growth_stages: int = 3

## Textures for each growth stage
@export var stage_textures: Array[Texture2D] = []
