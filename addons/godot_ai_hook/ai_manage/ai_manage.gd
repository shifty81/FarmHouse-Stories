extends Node
class_name AiManage

## AiManage - Core AI management node for Godot AI Hook.
## Attach as a child of any text-capable node to enable AI responses.
## Key methods:
##   say(content, system_prompt) - Send AI request with optional system prompt
##   say_bind_key(content, key) - Send request using a named prompt from SystemPromptConfig

@onready var chat_node_scene: PackedScene = preload("res://addons/godot_ai_hook/chat_node/chat_node.tscn")
@onready var chat_stream_node_scene: PackedScene = preload("res://addons/godot_ai_hook/chat_stream_node/chat_stream_node.tscn")

var chat_node: Node = null
var chat_stream_node: Node = null

@onready var parent: Node = get_parent()

var system_prompt: String = ""
var is_finished_transfer := true
var typing_interval: float
var sentence_pause_extra: float
var append_buffer: String = ""
var _append_accumulator: float = 0.0
var _is_typing: bool = false
var is_clean_before_reply: bool = true


func say(content: String, system_prompt: String = "") -> void:
	send_chat_request(content, system_prompt)


func say_bind_key(content: String, key: String) -> void:
	if content.is_empty():
		push_error("Content to send is empty")
		return
	if key == null or key.is_empty():
		push_error("system_prompt key is empty")
		return
	system_prompt = SystemPromptConfig.system_prompt_dic.get(key, "")
	if system_prompt is not String:
		push_error("system_prompt must be a String, please check the value for this key in SystemPromptConfig.system_prompt_dic")
		return
	if system_prompt.is_empty():
		push_error("SystemPromptConfig dictionary does not contain key %s" % key)
		return
	say(content, system_prompt)


func _ready() -> void:
	set_ai_stream_type(true)


func set_clean_before_reply(is_true: bool) -> void:
	is_clean_before_reply = is_true


func set_ai_stream_type(is_true: bool) -> void:
	if not is_finished_transfer:
		set_finished_transfer(true)

	for child in get_children():
		if is_instance_valid(child):
			child.queue_free()

	chat_node = null
	chat_stream_node = null

	if is_true:
		if chat_stream_node_scene == null:
			push_error("chat_stream_node_scene is not set")
			return
		chat_stream_node = chat_stream_node_scene.instantiate()
		add_child(chat_stream_node)
	else:
		if chat_node_scene == null:
			push_error("chat_node_scene is not set")
			return
		chat_node = chat_node_scene.instantiate()
		add_child(chat_node)


func set_finished_transfer(is_true: bool) -> void:
	is_finished_transfer = is_true


func get_finished_transfer_state() -> bool:
	return is_finished_transfer


func send_chat_request(content: String, system_prompt: String) -> void:
	typing_interval = AiConfig.append_interval_time
	sentence_pause_extra = AiConfig.sentence_pause_extra
	if is_clean_before_reply:
		clean_parent_text_content()

	if not is_finished_transfer:
		on_ai_error_occurred("AI is already generating")
		return

	on_ai_request_started()

	var has_sender := false

	for child in get_children():
		if not is_instance_valid(child):
			continue

		if not child.has_method("set_system_prompt") \
		or not child.has_method("send_chat_request"):
			continue

		child.set_system_prompt(system_prompt)
		child.send_chat_request(content)
		has_sender = true

	if not has_sender:
		on_ai_error_occurred("No available ChatNode found")
		return


func on_ai_request_started() -> void:
	set_finished_transfer(false)


func _process(delta: float) -> void:
	if not _is_typing:
		set_process(false)
		return

	if append_buffer.is_empty():
		_is_typing = false
		set_process(false)
		return

	_append_accumulator += delta
	if _append_accumulator < typing_interval:
		return
	var ch := append_buffer.substr(0, 1)
	append_buffer = append_buffer.substr(1)
	_append_text_safe(ch)

	if ch == "." or ch == "。" or ch == "!" or ch == "！" or ch == "?" or ch == "？":
		_append_accumulator = -sentence_pause_extra
	else:
		_append_accumulator = 0.0


func _enqueue_text(text: String) -> void:
	if text == null or text.is_empty():
		return
	append_buffer += text
	if not _is_typing:
		_is_typing = true
		set_process(true)


func _has_text_interface(node: Object) -> bool:
	return node != null \
		and node.has_method("set_text") \
		and node.has_method("get_text") \
		and typeof(node.get_text()) == TYPE_STRING


func clean_parent_text_content() -> void:
	if parent == null:
		push_error("AiManage: parent is null, cannot clear text")
		return

	if _has_text_interface(parent):
		parent.set_text("")
		return

	if parent.has_method("clear"):
		parent.clear()
		return

	push_error("AiManage: parent type does not support clearing text, type = " + parent.get_class())


func _append_text_safe(text: String) -> void:
	if parent == null:
		push_error("AiManage: parent is null")
		return

	if _has_text_interface(parent):
		var old_text: String = parent.get_text()
		if old_text == null:
			old_text = ""
		parent.set_text(str(old_text) + text)
		return

	if parent.has_method("append_text"):
		parent.append_text(text)
		return

	push_error("AiManage: parent does not support appending text, type = " + parent.get_class())


func on_ai_reasoning_content_generated(reasoning_content: String) -> void:
	_enqueue_text(reasoning_content)


func on_ai_content_generated(content: String) -> void:
	_enqueue_text(content)


func on_ai_generation_finished() -> void:
	set_finished_transfer(true)


func on_ai_error_occurred(err_msg: String) -> void:
	set_finished_transfer(true)
	_is_typing = false
	append_buffer = ""
	set_process(false)
	push_error("AI Error: " + str(err_msg))


func cancel_ai_transfer() -> void:
	is_finished_transfer = true

	for child in get_children():
		if not is_instance_valid(child):
			continue
		if child.has_method("_stop_stream"):
			child._stop_stream()
		if child.has_method("_safe_free_client"):
			child._safe_free_client()


func _exit_tree() -> void:
	cancel_ai_transfer()
