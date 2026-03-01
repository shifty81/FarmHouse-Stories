extends Node
## QuestManager - Tracks quest state across all NPCs.
## Pulls quest definitions from NPCDatabase and manages active/completed quests.

enum QuestState { NOT_STARTED, ACTIVE, COMPLETED }

## All known quests keyed by quest_id
var quests: Dictionary = {}

## Lists for quick lookup
var active_quests: Array[String] = []
var completed_quests: Array[String] = []


func _ready() -> void:
	_register_quests_from_npc_database()
	EventBus.npc_quest_started.connect(_on_npc_quest_started)
	EventBus.npc_quest_completed.connect(_on_npc_quest_completed)


func start_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	var quest: Dictionary = quests[quest_id]
	if quest.state != QuestState.NOT_STARTED:
		return false
	quest.state = QuestState.ACTIVE
	if quest_id not in active_quests:
		active_quests.append(quest_id)
	EventBus.quest_started.emit(quest_id, quest.npc_id)
	return true


func complete_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	var quest: Dictionary = quests[quest_id]
	if quest.state != QuestState.ACTIVE:
		return false
	quest.state = QuestState.COMPLETED
	active_quests.erase(quest_id)
	if quest_id not in completed_quests:
		completed_quests.append(quest_id)
	EventBus.quest_completed.emit(quest_id, quest.npc_id)
	return true


func get_quest(quest_id: String) -> Dictionary:
	return quests.get(quest_id, {})


func get_active_quests() -> Array:
	var result: Array = []
	for qid: String in active_quests:
		result.append(quests[qid].duplicate())
	return result


func get_completed_quests() -> Array:
	var result: Array = []
	for qid: String in completed_quests:
		result.append(quests[qid].duplicate())
	return result


func is_quest_active(quest_id: String) -> bool:
	return quest_id in active_quests


func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests


func _on_npc_quest_started(_npc_id: String, quest_id: String) -> void:
	if quests.has(quest_id):
		start_quest(quest_id)


func _on_npc_quest_completed(_npc_id: String, quest_id: String) -> void:
	if quests.has(quest_id):
		complete_quest(quest_id)


func _register_quests_from_npc_database() -> void:
	var npc_db: Node = get_node_or_null("/root/NPCDatabase")
	if not npc_db:
		return
	for npc_id: String in npc_db.get_all_npc_ids():
		var npc: Dictionary = npc_db.get_npc(npc_id)
		var chain: Array = npc.get("quest_chain", [])
		var reqs: Dictionary = npc.get("quest_requirements", {})
		for quest_id: String in chain:
			var req: Dictionary = reqs.get(quest_id, {})
			quests[quest_id] = {
				"id": quest_id,
				"npc_id": npc_id,
				"npc_name": npc.get("display_name", npc_id),
				"title": req.get("title", quest_id),
				"description": req.get("description", ""),
				"heart_level": req.get("heart_level", 0),
				"state": QuestState.NOT_STARTED
			}


func get_save_data() -> Dictionary:
	var quest_states: Dictionary = {}
	for qid: String in quests:
		quest_states[qid] = quests[qid].state
	return {
		"quest_states": quest_states,
		"active_quests": active_quests.duplicate(),
		"completed_quests": completed_quests.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	var states: Dictionary = data.get("quest_states", {})
	for qid: String in states:
		if quests.has(qid):
			quests[qid].state = states[qid]
	active_quests = data.get("active_quests", [])
	completed_quests = data.get("completed_quests", [])
