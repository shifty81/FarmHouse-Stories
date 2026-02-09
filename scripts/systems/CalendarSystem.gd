extends Node
## CalendarSystem - Manages in-game time, seasons, and day progression.

const SEASONS = ["Spring", "Summer", "Fall", "Winter"]
const DAYS_PER_SEASON = 28
const HOURS_PER_DAY = 24
const MINUTES_PER_HOUR = 60

## How fast time passes: 1 real second = time_scale game seconds
@export var time_scale: float = 60.0

var current_season_index: int = 0
var current_day: int = 1
var current_year: int = 1
var current_hour: int = 6
var current_minute: int = 0

var time_paused: bool = false
var time_accumulator: float = 0.0


func _ready():
	EventBus.current_day = current_day
	EventBus.current_season = SEASONS[current_season_index]
	EventBus.current_hour = current_hour


func _process(delta):
	if time_paused:
		return

	time_accumulator += delta * time_scale

	while time_accumulator >= 60.0:
		time_accumulator -= 60.0
		_advance_minute()


func _advance_minute():
	current_minute += 1

	if current_minute >= MINUTES_PER_HOUR:
		current_minute = 0
		_advance_hour()


func _advance_hour():
	current_hour += 1
	EventBus.hour_changed.emit(current_hour)

	# Force sleep at 2 AM next day
	if current_hour >= 26:
		end_day()


func end_day():
	EventBus.day_ended.emit()

	current_day += 1
	current_hour = 6
	current_minute = 0

	if current_day > DAYS_PER_SEASON:
		_advance_season()

	EventBus.current_day = current_day
	EventBus.current_hour = current_hour
	EventBus.day_started.emit(current_day, SEASONS[current_season_index])


func _advance_season():
	current_day = 1
	current_season_index = (current_season_index + 1) % SEASONS.size()

	if current_season_index == 0:
		current_year += 1

	EventBus.current_season = SEASONS[current_season_index]


func get_time_string() -> String:
	var display_hour = current_hour % 24
	var hour_12 = display_hour % 12
	if hour_12 == 0:
		hour_12 = 12
	var am_pm = "AM" if display_hour < 12 else "PM"
	return "%02d:%02d %s" % [hour_12, current_minute, am_pm]


func get_date_string() -> String:
	return "%s %d, Year %d" % [SEASONS[current_season_index], current_day, current_year]
