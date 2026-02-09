extends Node
## NPCAIDialogue - Adapter between DialogueSystem and Godot AI Hook.
## Captures AI responses without requiring a text-display parent node.
## Sends results back to DialogueSystem via callbacks.

var _chat_node_scene: PackedScene
var _chat_stream_node_scene: PackedScene
var _active_chat: Node = null

var _response_buffer: String = ""
var _is_transferring: bool = false

## Reference to the DialogueSystem that owns this node
var dialogue_system: Node = null

## Whether to use streaming mode
var use_streaming: bool = true


func _ready() -> void:
	_chat_node_scene = load("res://addons/godot_ai_hook/chat_node/chat_node.tscn")
	_chat_stream_node_scene = load("res://addons/godot_ai_hook/chat_stream_node/chat_stream_node.tscn")


## Send an AI chat request with the given content and system prompt.
func send_request(content: String, system_prompt: String) -> void:
	if _is_transferring:
		_on_error("AI is already generating a response")
		return

	if AiConfig.api_key.is_empty():
		_on_error("API key is not configured")
		return

	# Clean up any previous chat node
	if _active_chat and is_instance_valid(_active_chat):
		_active_chat.queue_free()
		_active_chat = null

	_response_buffer = ""
	_is_transferring = true

	# Instantiate the appropriate chat node
	if use_streaming and _chat_stream_node_scene:
		_active_chat = _chat_stream_node_scene.instantiate()
	elif _chat_node_scene:
		_active_chat = _chat_node_scene.instantiate()
	else:
		_on_error("No chat node scene available")
		return

	add_child(_active_chat)
	_active_chat.set_system_prompt(system_prompt)
	_active_chat.send_chat_request(content)


## Called by ChatNode/ChatStreamNode when content is generated.
func on_ai_content_generated(content: String) -> void:
	_response_buffer += content


## Called by ChatNode/ChatStreamNode when reasoning content is generated.
func on_ai_reasoning_content_generated(_reasoning_content: String) -> void:
	pass  # We don't display reasoning for NPC dialogue


## Called by ChatNode/ChatStreamNode when generation is complete.
func on_ai_generation_finished() -> void:
	_is_transferring = false
	var response: String = _response_buffer
	_response_buffer = ""

	if dialogue_system and dialogue_system.has_method("_on_ai_response_received"):
		dialogue_system._on_ai_response_received(response)


## Called by ChatNode/ChatStreamNode when an error occurs.
func on_ai_error_occurred(err_msg: String) -> void:
	_is_transferring = false
	_response_buffer = ""
	_on_error(err_msg)


func _on_error(err_msg: String) -> void:
	push_warning("NPCAIDialogue: " + err_msg)
	if dialogue_system and dialogue_system.has_method("_on_ai_error"):
		dialogue_system._on_ai_error(err_msg)


## Cancel any in-progress AI transfer.
func cancel() -> void:
	_is_transferring = false
	_response_buffer = ""
	if _active_chat and is_instance_valid(_active_chat):
		if _active_chat.has_method("_stop_stream"):
			_active_chat._stop_stream()
		if _active_chat.has_method("_safe_free_client"):
			_active_chat._safe_free_client()


func _exit_tree() -> void:
	cancel()
