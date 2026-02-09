extends Node
## DialogueSystem - Manages NPC dialogue trees, relationship-gated conversations,
## and quest dialogue. Tracks conversation state and emits signals for the UI.
## Supports AI-powered dynamic dialogue via the Godot AI Hook plugin.

## Dialogue state
var is_dialogue_active: bool = false
var current_npc_id: String = ""
var current_dialogue_lines: Array = []
var current_line_index: int = 0
var dialogue_history: Dictionary = {}  ## { npc_id: [seen_dialogue_keys] }

## AI dialogue state
var ai_enabled: bool = false
var _npc_ai: Node = null
var _ai_waiting: bool = false

## Maps NPC roles to system prompt keys in SystemPromptConfig
const ROLE_TO_PROMPT_KEY: Dictionary = {
	"Blacksmith": "npc_blacksmith",
	"Mayor": "npc_mayor",
	"Town Doctor": "npc_doctor",
	"Doctor": "npc_doctor",
	"Tavern Owner": "npc_tavern_owner",
	"Carpenter": "npc_carpenter",
	"Archaeologist/Scholar": "npc_scholar",
	"Myth-Keeper/Librarian": "npc_scholar",
	"Ranger/Guard Captain": "npc_ranger",
	"Void Anchor Vendor": "npc_void_vendor",
	"Hermit/Herbalist": "npc_herbalist",
}


func _ready() -> void:
	EventBus.npc_friendship_changed.connect(_on_friendship_changed)
	_setup_ai_dialogue()


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
func end_dialogue() -> void:
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


func _on_friendship_changed(_npc_id: String, _level: int) -> void:
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


# === AI Dialogue Integration (Godot AI Hook) ===


## Initialize the AI dialogue system. Creates an NPCAIDialogue adapter node
## that handles communication with the AI backend via Godot AI Hook.
func _setup_ai_dialogue() -> void:
	# Create an NPCAIDialogue adapter node
	_npc_ai = Node.new()
	_npc_ai.set_script(load("res://scripts/npc/NPCAIDialogue.gd"))
	_npc_ai.name = "NPCAIDialogue"
	add_child(_npc_ai)
	_npc_ai.dialogue_system = self
	# AI is enabled when a valid API key is configured
	ai_enabled = not AiConfig.api_key.is_empty()


## Request an AI-generated dialogue response for an NPC.
## Falls back to static dialogue if AI is unavailable or fails.
func request_ai_dialogue(npc_id: String, player_message: String) -> void:
	if not ai_enabled or _npc_ai == null or AiConfig.api_key.is_empty():
		# Fall back to static dialogue
		start_dialogue(npc_id)
		return

	if _ai_waiting:
		return

	var npc: Dictionary = NPCDatabase.get_npc(npc_id)
	if npc.is_empty():
		return

	var npc_name: String = npc.get("display_name", npc.get("name", "Villager"))
	var role: String = npc.get("occupation", npc.get("role", ""))
	var friendship: int = npc.get("friendship_level", 0)
	var backstory: String = npc.get("backstory", "")

	# Build a context-rich system prompt
	var system_prompt: String = _build_npc_system_prompt(npc_id, npc_name, role, friendship, backstory)

	_ai_waiting = true
	current_npc_id = npc_id

	EventBus.ai_dialogue_requested.emit(npc_id, player_message)

	# Use the NPCAIDialogue adapter to send the request
	_npc_ai.send_request(player_message, system_prompt)


## Build a system prompt for an NPC based on their character data.
func _build_npc_system_prompt(_npc_id: String, npc_name: String, role: String, friendship: int, backstory: String) -> String:
	# Start with role-based prompt if available
	var prompt_key: String = ROLE_TO_PROMPT_KEY.get(role, "npc_default")
	var base_prompt: String = SystemPromptConfig.system_prompt_dic.get(prompt_key, "")
	if base_prompt.is_empty():
		base_prompt = SystemPromptConfig.system_prompt_dic.get("npc_default", "")

	# Enrich with character-specific context
	var context: String = base_prompt
	context += "\n\nCharacter details:"
	context += "\n- Your name is %s." % npc_name
	if role != "":
		context += "\n- Your role/occupation: %s." % role
	context += "\n- Your friendship level with the player: %d/10 hearts." % friendship
	if friendship >= 8:
		context += " You consider the player a dear friend."
	elif friendship >= 5:
		context += " You are friendly with the player."
	elif friendship >= 2:
		context += " You are acquainted with the player."
	else:
		context += " You barely know the player."

	if backstory != "":
		context += "\n- Background: %s" % backstory

	context += "\n\nCurrent season: %s, Day %d." % [EventBus.current_season, EventBus.current_day]
	context += "\nKeep your response in-character, brief (1-3 sentences), and do not break the fourth wall."

	return context


## Called by NPCAIDialogue when the AI response is received.
func _on_ai_response_received(response: String) -> void:
	_ai_waiting = false
	if response.is_empty():
		# AI returned empty, fall back to static
		start_dialogue(current_npc_id)
		return

	var npc: Dictionary = NPCDatabase.get_npc(current_npc_id)
	var npc_name: String = npc.get("display_name", npc.get("name", "Villager"))

	# Create a dialogue line from the AI response
	current_dialogue_lines = [{
		"speaker": npc_name,
		"key": current_npc_id + "_ai_response",
		"text": response,
		"ai_generated": true
	}]
	current_line_index = 0
	is_dialogue_active = true

	EventBus.ai_dialogue_received.emit(current_npc_id, response)
	EventBus.npc_dialogue_triggered.emit(current_npc_id, "ai_greeting")
	EventBus.dialogue_started.emit()


## Called by NPCAIDialogue when an AI error occurs. Falls back to static dialogue.
func _on_ai_error(err_msg: String) -> void:
	_ai_waiting = false
	EventBus.ai_dialogue_error.emit(current_npc_id, err_msg)
	# Fall back to static dialogue
	start_dialogue(current_npc_id)


## Check if AI dialogue is available and configured.
func is_ai_available() -> bool:
	return ai_enabled and _npc_ai != null and not AiConfig.api_key.is_empty()


## Enable or disable AI-powered dialogue at runtime.
func set_ai_enabled(enabled: bool) -> void:
	ai_enabled = enabled
