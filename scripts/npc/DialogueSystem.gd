extends Node
## DialogueSystem - Manages NPC dialogue trees, relationship-gated conversations,
## and quest dialogue. Tracks conversation state and emits signals for the UI.

## Dialogue state
var is_dialogue_active: bool = false
var current_npc_id: String = ""
var current_dialogue_lines: Array = []
var current_line_index: int = 0
var dialogue_history: Dictionary = {}  ## { npc_id: [seen_dialogue_keys] }


func _ready():
	EventBus.npc_friendship_changed.connect(_on_friendship_changed)


## Start a dialogue with an NPC. Selects appropriate dialogue based on
## friendship level and quest state.
func start_dialogue(npc_id: String) -> bool:
	if is_dialogue_active:
		return false

	var npc = NPCDatabase.get_npc(npc_id)
	if npc.is_empty():
		return false

	current_npc_id = npc_id
	current_dialogue_lines = _get_dialogue_for_npc(npc_id, npc)
	current_line_index = 0

	if current_dialogue_lines.is_empty():
		return false

	is_dialogue_active = true
	EventBus.npc_dialogue_triggered.emit(npc_id, "greeting")
	EventBus.dialogue_started.emit()
	return true


## Advance to the next line of dialogue. Returns the line dict or empty if done.
func advance_dialogue() -> Dictionary:
	if not is_dialogue_active:
		return {}

	if current_line_index >= current_dialogue_lines.size():
		end_dialogue()
		return {}

	var line = current_dialogue_lines[current_line_index]
	current_line_index += 1

	# If this was the last line, end dialogue after returning it
	if current_line_index >= current_dialogue_lines.size():
		# Mark dialogue as seen
		if not dialogue_history.has(current_npc_id):
			dialogue_history[current_npc_id] = []
		var key = line.get("key", "")
		if key != "" and key not in dialogue_history[current_npc_id]:
			dialogue_history[current_npc_id].append(key)

	return line


## End the current dialogue.
func end_dialogue():
	if not is_dialogue_active:
		return

	is_dialogue_active = false
	current_npc_id = ""
	current_dialogue_lines.clear()
	current_line_index = 0
	EventBus.dialogue_ended.emit()


## Get a gift response dialogue for giving an item to an NPC.
func get_gift_response(npc_id: String, item_id: String) -> Dictionary:
	var npc = NPCDatabase.get_npc(npc_id)
	if npc.is_empty():
		return {}

	var npc_name = npc.get("name", "Villager")
	var loved_gifts = npc.get("loved_gifts", [])
	var liked_gifts = npc.get("liked_gifts", [])
	var disliked_gifts = npc.get("disliked_gifts", [])

	if item_id in loved_gifts:
		return {
			"speaker": npc_name,
			"text": "Oh, this is wonderful! I love it! Thank you so much!",
			"mood": "loved"
		}
	elif item_id in liked_gifts:
		return {
			"speaker": npc_name,
			"text": "How thoughtful! I appreciate this gift.",
			"mood": "liked"
		}
	elif item_id in disliked_gifts:
		return {
			"speaker": npc_name,
			"text": "Oh... um, thanks, I suppose...",
			"mood": "disliked"
		}
	else:
		return {
			"speaker": npc_name,
			"text": "Thank you for the gift.",
			"mood": "neutral"
		}


## Check if a specific dialogue has been seen.
func has_seen_dialogue(npc_id: String, dialogue_key: String) -> bool:
	if dialogue_history.has(npc_id):
		return dialogue_key in dialogue_history[npc_id]
	return false


## Build dialogue lines for an NPC based on their data and friendship level.
func _get_dialogue_for_npc(npc_id: String, npc: Dictionary) -> Array:
	var lines: Array = []
	var npc_name = npc.get("name", "Villager")
	var friendship = npc.get("friendship_level", 0)
	var role = npc.get("role", "")
	var quest_requirements = npc.get("quest_requirements", {})

	# Check for available quest dialogue first
	var quest_line = _get_quest_dialogue(npc_id, npc_name, friendship, quest_requirements)
	if not quest_line.is_empty():
		return quest_line

	# Relationship-tier greetings
	if friendship >= 8:
		lines.append({
			"speaker": npc_name, "key": npc_id + "_greeting_high",
			"text": "It's so good to see you, dear friend! You're always welcome here."
		})
	elif friendship >= 5:
		lines.append({
			"speaker": npc_name, "key": npc_id + "_greeting_mid",
			"text": "Hey there! Always nice to have you stop by."
		})
	elif friendship >= 2:
		lines.append({
			"speaker": npc_name, "key": npc_id + "_greeting_low",
			"text": "Oh, hello. Good to see you around town."
		})
	else:
		lines.append({
			"speaker": npc_name, "key": npc_id + "_greeting_new",
			"text": "Hello there. I don't think we've talked much yet."
		})

	# Role-based flavor dialogue
	var role_line = _get_role_dialogue(npc_name, role)
	if not role_line.is_empty():
		lines.append(role_line)

	return lines


## Generate quest dialogue when the player meets heart-level requirements.
func _get_quest_dialogue(npc_id: String, npc_name: String, friendship: int, quest_requirements: Dictionary) -> Array:
	var lines: Array = []

	for quest_id in quest_requirements:
		var quest = quest_requirements[quest_id]
		var required_hearts = quest.get("heart_level", 0)
		var quest_title = quest.get("title", "")
		var quest_desc = quest.get("description", "")

		# Only offer quest if friendship is high enough and not already seen
		if friendship >= required_hearts and not has_seen_dialogue(npc_id, quest_id):
			lines.append({
				"speaker": npc_name, "key": quest_id,
				"text": quest_desc if quest_desc != "" else quest_title,
				"quest_id": quest_id
			})
			lines.append({
				"speaker": npc_name, "key": quest_id + "_accept",
				"text": "Will you help me with this?"
			})
			EventBus.npc_quest_started.emit(npc_id, quest_id)
			return lines

	return []


## Return a role-specific flavor line.
func _get_role_dialogue(npc_name: String, role: String) -> Dictionary:
	match role:
		"Blacksmith":
			return {"speaker": npc_name, "key": "role_blacksmith",
				"text": "If you need tools upgraded or weapons forged, you know where to find me."}
		"Town Doctor":
			return {"speaker": npc_name, "key": "role_doctor",
				"text": "Stay healthy out there. If the Rift sickness gets to you, come see me right away."}
		"Doctor":
			return {"speaker": npc_name, "key": "role_doctor",
				"text": "Stay healthy out there. If the Rift sickness gets to you, come see me right away."}
		"Carpenter":
			return {"speaker": npc_name, "key": "role_carpenter",
				"text": "Need any buildings constructed or repaired? I've got the lumber for it."}
		"Archaeologist/Scholar":
			return {"speaker": npc_name, "key": "role_scholar",
				"text": "I've been studying the ancient texts. The Rifts hold secrets we've barely begun to uncover."}
		"Myth-Keeper/Librarian":
			return {"speaker": npc_name, "key": "role_scholar",
				"text": "I've been studying the ancient texts. The Rifts hold secrets we've barely begun to uncover."}
		"Tavern Owner":
			return {"speaker": npc_name, "key": "role_tavern",
				"text": "Pull up a stool! The Bludgeoned Barrister is always open for good company."}
		"Mayor":
			return {"speaker": npc_name, "key": "role_mayor",
				"text": "Hearthhaven is a fine town, but we must remain vigilant against the Rift threats."}
		"Ranger/Guard Captain":
			return {"speaker": npc_name, "key": "role_ranger",
				"text": "The mountains have been restless lately. Keep your gear sharp if you head that way."}
		"Void Anchor Vendor":
			return {"speaker": npc_name, "key": "role_void_vendor",
				"text": "The Rifts call to those who dare... Do you have enough Chronos Shards to enter?"}
		"Hermit/Herbalist":
			return {"speaker": npc_name, "key": "role_hermit",
				"text": "The old ways still hold power... I can brew you something if you bring the right herbs."}
		_:
			return {}


func _on_friendship_changed(_npc_id: String, _level: int):
	pass  # Could trigger new dialogue availability notifications


## Save dialogue state.
func get_save_data() -> Dictionary:
	return {
		"dialogue_history": dialogue_history.duplicate(true)
	}


## Load dialogue state.
func load_save_data(data: Dictionary) -> void:
	if data.has("dialogue_history"):
		dialogue_history = data.dialogue_history
