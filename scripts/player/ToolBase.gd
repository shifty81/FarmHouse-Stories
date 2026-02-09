class_name ToolBase extends Resource
## ToolBase - Base class for all player tools (hoe, watering can, etc.).

@export var tool_name: String = ""
@export var tool_type: String = ""
@export var energy_cost: int = 2
@export var use_range: float = 40.0
@export var upgrade_level: int = 0


func use(user: CharacterBody2D, target_position: Vector2) -> bool:
	if EventBus.player_energy < energy_cost:
		print("Not enough energy!")
		return false

	EventBus.player_energy -= energy_cost
	EventBus.player_energy_changed.emit(EventBus.player_energy, EventBus.player_max_energy)

	return perform_action(user, target_position)


func perform_action(_user: CharacterBody2D, _target_position: Vector2) -> bool:
	return false
