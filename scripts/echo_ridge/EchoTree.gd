extends StaticBody2D
## EchoTree - The ancient, magical tree at the center of Echo Ridge Farm.
## Awakens and grows as the farm is restored.

enum Stage { DORMANT, AWAKENING, BUDDING, BLOOMING, RADIANT, SANCTUARY }

@export var current_stage: Stage = Stage.DORMANT
@export var growth_day_thresholds: Dictionary = {
	Stage.AWAKENING: 21,
	Stage.BUDDING: 35,
	Stage.BLOOMING: 50,
	Stage.RADIANT: 70,
	Stage.SANCTUARY: 365  # Year 2
}

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

## Visual stages (these would be actual sprite frames in production)
var stage_visuals: Dictionary = {
	Stage.DORMANT: "Completely leafless, dark bark",
	Stage.AWAKENING: "Small green buds appear",
	Stage.BUDDING: "Quarter-covered in leaves",
	Stage.BLOOMING: "Half-covered, small flowers",
	Stage.RADIANT: "Full foliage, glowing blossoms",
	Stage.SANCTUARY: "Spirits visibly gather, ethereal glow"
}


func _ready() -> void:
	add_to_group("interactables")
	update_appearance()

	# Connect to calendar system
	if Calendar:
		Calendar.day_changed.connect(_on_day_changed)


func _on_day_changed(_day: int, _season: String) -> void:
	## Check if tree should advance to next stage.
	check_growth_stage()


func check_growth_stage() -> void:
	## Check current day against growth thresholds.
	if not Calendar:
		return

	var total_days: int = Calendar.get_total_days()

	# Check stages in reverse order (highest to lowest)
	for stage: Stage in [Stage.SANCTUARY, Stage.RADIANT, Stage.BLOOMING, Stage.BUDDING, Stage.AWAKENING]:
		if total_days >= growth_day_thresholds[stage] and current_stage < stage:
			advance_to_stage(stage)
			return


func advance_to_stage(new_stage: Stage) -> void:
	## Advance tree to a new growth stage.
	if new_stage <= current_stage:
		return

	current_stage = new_stage
	update_appearance()

	EventBus.echo_tree_stage_changed.emit(current_stage)

	# Special events
	if current_stage == Stage.AWAKENING:
		EventBus.echo_tree_awakened.emit()
		show_awakening_event()
	elif current_stage == Stage.SANCTUARY:
		show_sanctuary_event()


func update_appearance() -> void:
	## Update visual representation based on current stage.
	if not sprite:
		return

	# TODO: In production, switch sprite frames here
	# For now, use modulate to show growth
	match current_stage:
		Stage.DORMANT:
			sprite.modulate = Color(0.4, 0.4, 0.4)
		Stage.AWAKENING:
			sprite.modulate = Color(0.5, 0.6, 0.5)
		Stage.BUDDING:
			sprite.modulate = Color(0.6, 0.8, 0.6)
		Stage.BLOOMING:
			sprite.modulate = Color(0.7, 1.0, 0.7)
		Stage.RADIANT:
			sprite.modulate = Color(0.9, 1.2, 0.9)
		Stage.SANCTUARY:
			sprite.modulate = Color(1.2, 1.5, 1.2)


func show_awakening_event() -> void:
	## Show special event when tree first awakens.
	# TODO: Play awakening animation/cutscene
	# TODO: Trigger spirit orb dialogue
	pass


func show_sanctuary_event() -> void:
	## Show special event when tree becomes a spirit sanctuary.
	# TODO: Play sanctuary animation
	# TODO: Spawn spirit NPCs around tree
	pass


func interact() -> void:
	## Called when player interacts with the tree.
	show_tree_info()


func show_tree_info() -> void:
	## Display information about the tree's current state.
	var _stage_name: String = Stage.keys()[current_stage]
	var _description: String = stage_visuals[current_stage]

	# TODO: Show dialogue UI with tree lore
	pass


func can_harvest_echo_fruit() -> bool:
	## Check if Echo Fruit is available for harvest.
	return current_stage >= Stage.SANCTUARY


func harvest_echo_fruit() -> void:
	## Harvest rare Echo Fruit (once per season).
	if not can_harvest_echo_fruit():
		return

	# TODO: Check if already harvested this season
	# TODO: Add Echo Fruit item to player inventory
	EventBus.special_item_obtained.emit("echo_fruit")
