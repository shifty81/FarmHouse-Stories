extends CanvasLayer
## NotificationSystem - Displays floating toast notifications.
## Shows brief text messages that fade in, linger, and fade out.
## Connect to EventBus signals for automatic player feedback.

const MAX_VISIBLE: int = 4
const DISPLAY_TIME: float = 3.0
const FADE_TIME: float = 0.5
const SLIDE_OFFSET: float = 30.0

var _queue: Array[String] = []
var _active_labels: Array[Label] = []

@onready var container: VBoxContainer = $MarginContainer/VBoxContainer


func _ready() -> void:
	_connect_signals()


func show_notification(text: String) -> void:
	if _active_labels.size() >= MAX_VISIBLE:
		_queue.append(text)
		return
	_create_label(text)


func _connect_signals() -> void:
	EventBus.crop_planted.connect(
		func(_pos, crop): show_notification("Planted %s" % crop))
	EventBus.crop_harvested.connect(
		func(_pos, crop, _q): show_notification(
			"Harvested %s" % crop))
	EventBus.crop_watered.connect(
		func(_pos): show_notification("Watered crop"))
	EventBus.inventory_item_added.connect(
		func(item, qty): show_notification(
			"+%d %s" % [qty, item]))
	EventBus.quest_started.connect(
		func(quest, _npc): show_notification(
			"Quest started: %s" % quest))
	EventBus.quest_completed.connect(
		func(quest, _npc): show_notification(
			"Quest complete: %s" % quest))
	EventBus.fish_caught.connect(
		func(fish): show_notification("Caught %s!" % fish))
	EventBus.dungeon_entered.connect(
		func(d): show_notification("Entered %s" % d))
	EventBus.seasonal_event_started.connect(
		func(e): show_notification("Event: %s" % e))
	EventBus.gear_set_changed.connect(
		func(s): show_notification(
			"Gear: %s set" % s.capitalize()))


func _create_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(1, 1, 1, 0)
	label.add_theme_font_size_override("font_size", 14)
	container.add_child(label)
	_active_labels.append(label)
	_animate_label(label)


func _animate_label(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(
		label, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(DISPLAY_TIME)
	tween.tween_property(
		label, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_remove_label.bind(label))


func _remove_label(label: Label) -> void:
	_active_labels.erase(label)
	label.queue_free()
	if _queue.size() > 0:
		var next_text: String = _queue.pop_front()
		_create_label(next_text)
