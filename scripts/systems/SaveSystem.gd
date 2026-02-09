extends Node
## SaveSystem - Handles saving and loading game state to/from disk.

const SAVE_FILE = "user://farmhouse_save.json"

func save_game() -> bool:
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"player": {
			"position": {"x": 0, "y": 0},
			"money": EventBus.player_money,
			"energy": EventBus.player_energy,
		},
		"calendar": {
			"day": EventBus.current_day,
			"season": EventBus.current_season,
			"hour": EventBus.current_hour,
		},
		"farm": {}
	}

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully!")
		return true
	else:
		print("Failed to save game!")
		return false


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found")
		return {}

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		print("Failed to open save file")
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("Failed to parse save file")
		return {}

	print("Game loaded successfully!")
	return json.data


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)
