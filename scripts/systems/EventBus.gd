extends Node
## EventBus - Global signal hub for FarmHouse Stories.
## Provides signals for decoupled communication between game systems.

# Time signals
signal day_started(day: int, season: String)
signal day_ended
signal hour_changed(hour: int)

# Player signals
signal player_energy_changed(energy: int, max_energy: int)
signal player_money_changed(money: int)
signal player_position_changed(position: Vector2)

# Farm signals
signal crop_planted(position: Vector2i, crop_type: String)
signal crop_watered(position: Vector2i)
signal crop_harvested(position: Vector2i, crop_type: String, quality: int)

# UI signals
signal inventory_opened
signal inventory_closed
signal dialogue_started
signal dialogue_ended

# Global game state
var current_day: int = 1
var current_season: String = "Spring"
var current_hour: int = 6
var player_money: int = 500
var player_energy: int = 100
var player_max_energy: int = 100
