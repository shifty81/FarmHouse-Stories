class_name NPCData extends Resource
## NPCData - Data definition for an NPC citizen of Hearthhaven.

@export var npc_id: String = ""
@export var display_name: String = ""
@export var age: int = 25
@export var occupation: String = ""
@export var personality: String = ""
@export_multiline var backstory: String = ""
@export var home_location: String = ""
@export var work_location: String = ""
@export var favorite_gifts: Array[String] = []
@export var disliked_gifts: Array[String] = []
@export var birthday_season: String = "Spring"
@export var birthday_day: int = 1

## Daily schedule: Dictionary of hour -> location
@export var daily_schedule: Dictionary = {}

## Dialogue keys mapped to friendship levels
@export var dialogue_by_friendship: Dictionary = {}

## Quest chain IDs associated with this NPC
@export var quest_chain: Array[String] = []

## Friendship level (0-10 hearts)
var friendship_level: int = 0
var friendship_points: int = 0

const POINTS_PER_LEVEL: int = 250
const MAX_LEVEL: int = 10


func add_friendship(points: int) -> bool:
	friendship_points += points
	var new_level: int = mini(friendship_points / POINTS_PER_LEVEL, MAX_LEVEL)
	if new_level != friendship_level:
		friendship_level = new_level
		return true
	return false


func get_current_location(hour: int) -> String:
	var best_hour = -1
	var location = home_location
	for schedule_hour in daily_schedule:
		var h = int(schedule_hour)
		if h <= hour and h > best_hour:
			best_hour = h
			location = daily_schedule[schedule_hour]
	return location
