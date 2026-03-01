extends CanvasLayer
## QuestJournal - UI panel for viewing active and completed quests.
## Toggle with the quest_journal input action (J key).

var _visible: bool = false

@onready var panel = $Panel
@onready var tab_container = $Panel/MarginContainer/VBoxContainer/TabContainer
@onready var active_list = $Panel/MarginContainer/VBoxContainer/TabContainer/Active/ItemList
@onready var completed_list = $Panel/MarginContainer/VBoxContainer/TabContainer/Completed/ItemList
@onready var detail_label = $Panel/MarginContainer/VBoxContainer/DetailPanel/DetailLabel
@onready var close_button = $Panel/MarginContainer/VBoxContainer/Header/CloseButton


func _ready() -> void:
	panel.visible = false
	close_button.pressed.connect(_toggle)
	active_list.item_selected.connect(_on_active_item_selected)
	completed_list.item_selected.connect(_on_completed_item_selected)
	EventBus.quest_started.connect(_on_quest_changed)
	EventBus.quest_completed.connect(_on_quest_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quest_journal"):
		_toggle()
		get_viewport().set_input_as_handled()


func _toggle() -> void:
	_visible = not _visible
	panel.visible = _visible
	if _visible:
		_refresh()
		EventBus.quest_journal_opened.emit()
	else:
		EventBus.quest_journal_closed.emit()


func _refresh() -> void:
	_refresh_active()
	_refresh_completed()
	detail_label.text = "Select a quest to view details."


func _refresh_active() -> void:
	active_list.clear()
	var quest_mgr: Node = get_node_or_null("/root/QuestManager")
	if not quest_mgr:
		return
	for quest: Dictionary in quest_mgr.get_active_quests():
		active_list.add_item(quest.title)
		active_list.set_item_metadata(
			active_list.item_count - 1, quest.id
		)


func _refresh_completed() -> void:
	completed_list.clear()
	var quest_mgr: Node = get_node_or_null("/root/QuestManager")
	if not quest_mgr:
		return
	for quest: Dictionary in quest_mgr.get_completed_quests():
		completed_list.add_item(quest.title)
		completed_list.set_item_metadata(
			completed_list.item_count - 1, quest.id
		)


func _on_active_item_selected(index: int) -> void:
	var quest_id: String = active_list.get_item_metadata(index)
	_show_detail(quest_id)


func _on_completed_item_selected(index: int) -> void:
	var quest_id: String = completed_list.get_item_metadata(index)
	_show_detail(quest_id)


func _show_detail(quest_id: String) -> void:
	var quest_mgr: Node = get_node_or_null("/root/QuestManager")
	if not quest_mgr:
		return
	var quest: Dictionary = quest_mgr.get_quest(quest_id)
	if quest.is_empty():
		return
	detail_label.text = "%s\nFrom: %s\n\n%s" % [
		quest.title, quest.npc_name, quest.description
	]


func _on_quest_changed(_quest_id: String, _npc_id: String) -> void:
	if _visible:
		_refresh()
