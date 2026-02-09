class_name ChatNode
extends Node

## ChatNode - Non-streaming AI chat implementation.
## Uses HTTPRequest to send a single request and parse the full JSON response.

var url: String
var api_key: String
var model: String
@onready var parent: Node = get_parent()

var system_prompt := ""
var client: HTTPRequest = null


func set_system_prompt(prompt: String) -> void:
	system_prompt = prompt


func _load_config() -> void:
	api_key = AiConfig.api_key
	model = AiConfig.model
	url = AiConfig.url


func send_chat_request(content: String) -> void:
	_load_config()

	if api_key.is_empty():
		parent.on_ai_error_occurred("API_KEY is empty")
		return

	if url.is_empty():
		parent.on_ai_error_occurred("API URL is empty")
		return

	if model.is_empty():
		parent.on_ai_error_occurred("Model is empty")
		return

	if content.is_empty():
		parent.on_ai_error_occurred("Content to send is empty")
		return

	client = HTTPRequest.new()
	add_child(client)
	client.request_completed.connect(_on_request_completed)

	var headers: Array = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]

	var body: Dictionary = {
		"model": model,
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": content}
		]
	}

	var json_body: String = JSON.stringify(body)

	var err := client.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if err != OK:
		parent.on_ai_error_occurred(
			"Failed to start HTTP request, error code: " + str(err)
		)
		_safe_free_client()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		parent.on_ai_error_occurred(
			"HTTP request failed, result=" + str(result)
		)
		_safe_free_client()
		return

	if response_code != 200:
		var err_text: String = body.get_string_from_utf8()
		parent.on_ai_error_occurred(
			"HTTP error code: %d\n%s" % [response_code, err_text]
		)
		_safe_free_client()
		return

	var text: String = body.get_string_from_utf8()
	if text.is_empty():
		parent.on_ai_error_occurred("Response body is empty")
		_safe_free_client()
		return

	var json := JSON.new()
	var parse_result := json.parse(text)
	if parse_result != OK:
		parent.on_ai_error_occurred(
			"JSON parse failed: " + str(parse_result)
		)
		_safe_free_client()
		return

	var data: Dictionary = json.get_data()

	if not data.has("choices"):
		parent.on_ai_error_occurred("Response is missing 'choices' field")
		_safe_free_client()
		return

	if data["choices"].is_empty():
		parent.on_ai_error_occurred("'choices' array is empty")
		_safe_free_client()
		return

	var choice: Dictionary = data["choices"][0]
	if not choice.has("message") or not choice["message"].has("content"):
		parent.on_ai_error_occurred("Response structure is incomplete")
		_safe_free_client()
		return

	var message_content: String = choice["message"]["content"]
	parent.on_ai_content_generated(message_content)
	parent.on_ai_generation_finished()

	_safe_free_client()


func _safe_free_client() -> void:
	if client and is_instance_valid(client):
		client.queue_free()
	client = null
