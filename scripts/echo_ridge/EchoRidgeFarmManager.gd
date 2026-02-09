extends Node
## EchoRidgeFarmManager - Manages the state of Echo Ridge Farm.
## Tracks debris clearing, farm restoration progress, and story events.

@export var total_debris_count: int = 100
@export var farm_worth_goal: int = 1000  # Gold needed to prove farm worth

var debris_cleared: int = 0
var current_farm_value: int = 0

# Story flags
var havenport_rep_visited: bool = false
var farm_worth_proven: bool = false
var greenhouse_unlocked: bool = false
var creek_purified: bool = false

# Debris type counters
var debris_counts: Dictionary = {
	"sticks": 30,
	"stones": 30,
	"weeds": 20,
	"stumps": 20
}


func _ready() -> void:
	# Calculate total debris
	total_debris_count = 0
	for count: int in debris_counts.values():
		total_debris_count += count

	# Connect to calendar for story events
	if Calendar:
		Calendar.day_changed.connect(_on_day_changed)

	# Connect to money changes
	if EventBus:
		EventBus.player_money_changed.connect(_on_money_changed)


func _on_day_changed(day: int, season: String) -> void:
	## Handle day-based story events.
	# Havenport representative visits on Day 14
	if day == 14 and season == "Spring" and not havenport_rep_visited:
		trigger_havenport_visit()


func trigger_havenport_visit() -> void:
	## Trigger the Havenport representative visit event.
	havenport_rep_visited = true
	EventBus.havenport_representative_visit.emit()
	# TODO: Show cutscene/dialogue


func debris_cleared_by_player(debris_type: String) -> void:
	## Called when player clears a debris object.
	if debris_counts.has(debris_type) and debris_counts[debris_type] > 0:
		debris_counts[debris_type] -= 1
		debris_cleared += 1

		# Emit progress signal
		var clear_percentage: float = get_clear_percentage()
		EventBus.farm_cleared_percentage.emit(clear_percentage)


func get_clear_percentage() -> float:
	## Get the percentage of farm that has been cleared.
	if total_debris_count == 0:
		return 1.0
	return float(debris_cleared) / float(total_debris_count)


func _on_money_changed(money: int) -> void:
	## Check if farm worth goal has been reached.
	if not farm_worth_proven and money >= farm_worth_goal and havenport_rep_visited:
		prove_farm_worth()


func prove_farm_worth() -> void:
	## Mark farm worth as proven.
	farm_worth_proven = true
	EventBus.farm_worth_proven.emit()
	# TODO: Show achievement/quest completion


func unlock_greenhouse() -> void:
	## Unlock the greenhouse for restoration.
	greenhouse_unlocked = true
	# TODO: Enable greenhouse restoration quest


func purify_creek() -> void:
	## Mark creek as purified.
	creek_purified = true
	# TODO: Enable fishing and irrigation


## Return data to save.
func get_save_data() -> Dictionary:
	return {
		"debris_cleared": debris_cleared,
		"debris_counts": debris_counts,
		"havenport_rep_visited": havenport_rep_visited,
		"farm_worth_proven": farm_worth_proven,
		"greenhouse_unlocked": greenhouse_unlocked,
		"creek_purified": creek_purified
	}


func load_save_data(data: Dictionary) -> void:
	## Load saved data.
	debris_cleared = data.get("debris_cleared", 0)
	debris_counts = data.get("debris_counts", debris_counts)
	havenport_rep_visited = data.get("havenport_rep_visited", false)
	farm_worth_proven = data.get("farm_worth_proven", false)
	greenhouse_unlocked = data.get("greenhouse_unlocked", false)
	creek_purified = data.get("creek_purified", false)

	# Emit current state
	EventBus.farm_cleared_percentage.emit(get_clear_percentage())
