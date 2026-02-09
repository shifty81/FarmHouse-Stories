extends Node

## ChatStreamNode - Streaming AI chat implementation.
## Uses HTTPClient to establish an SSE connection for real-time token streaming.

@onready var parent: Node = get_parent()

var api_key: String
var model: String
var host: String
var path: String
var port: int

const STREAM_TIMEOUT := 20.0

var _last_data_time := 0.0

var system_prompt := ""
var content := ""

var client := HTTPClient.new()
var buffer := ""

var _request_sent := false


func set_system_prompt(prompt: String) -> void:
	system_prompt = prompt


func _load_config() -> void:
	api_key = AiConfig.api_key
	model = AiConfig.model
	host = AiConfig.get_stream_url_host()
	path = AiConfig.get_stream_url_path()
	port = AiConfig.port


func send_chat_request(p_content: String) -> void:
	_load_config()
	_last_data_time = Time.get_unix_time_from_system()

	content = p_content

	if api_key.is_empty():
		parent.on_ai_error_occurred("API_KEY is not set")
		return

	if host.is_empty() or path.is_empty():
		parent.on_ai_error_occurred("Stream URL configuration is invalid")
		return

	if model.is_empty():
		parent.on_ai_error_occurred("Model is not set")
		return

	if content.is_empty():
		parent.on_ai_error_occurred("Content to send is empty")
		return

	buffer = ""
	_request_sent = false

	var err := client.connect_to_host(host, port, TLSOptions.client())
	if err != OK:
		parent.on_ai_error_occurred("Failed to connect to host: " + str(err))
		return

	set_process(true)


func _process(_delta: float) -> void:
	client.poll()

	if _last_data_time == 0:
		return
	if Time.get_unix_time_from_system() - _last_data_time > STREAM_TIMEOUT:
		parent.on_ai_error_occurred("AI response timed out")
		_stop_stream()
		return

	match client.get_status():
		HTTPClient.STATUS_CONNECTING:
			pass

		HTTPClient.STATUS_CONNECTED:
			if not _request_sent:
				_send_request()

		HTTPClient.STATUS_REQUESTING:
			pass

		HTTPClient.STATUS_BODY:
			_read_stream_body()

		HTTPClient.STATUS_DISCONNECTED:
			parent.on_ai_error_occurred("Connection disconnected")
			_stop_stream()

		_:
			pass


func _send_request() -> void:
	_request_sent = true

	var body: Dictionary = {
		"model": model,
		"stream": true,
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": content}
		]
	}

	var headers: Array = [
		"Host: %s" % host,
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key,
		"Accept: text/event-stream"
	]

	var err := client.request(
		HTTPClient.METHOD_POST,
		path,
		headers,
		JSON.stringify(body)
	)

	if err != OK:
		parent.on_ai_error_occurred("Failed to send streaming request: " + str(err))
		_stop_stream()


func _read_stream_body() -> void:
	while true:
		while client.get_status() != HTTPClient.STATUS_BODY:
			await get_tree().process_frame

		var chunk: PackedByteArray = client.read_response_body_chunk()
		if chunk.is_empty():
			break
		_on_data(chunk)


func _on_data(data: PackedByteArray) -> void:
	_last_data_time = Time.get_unix_time_from_system()

	var text: String = data.get_string_from_utf8()
	if text.is_empty():
		return

	buffer += text

	while buffer.find("\n") != -1:
		var i: int = buffer.find("\n")
		var line: String = buffer.substr(0, i).strip_edges()
		buffer = buffer.substr(i + 1)
		if line.is_empty():
			continue

		if not line.begins_with("data:"):
			continue

		var payload: String = line.substr(5).strip_edges()
		if payload == "[DONE]":
			parent.on_ai_generation_finished()
			_stop_stream()
			return

		_handle_chunk(payload)


func _handle_chunk(json_text: String) -> void:
	var result: Variant = JSON.parse_string(json_text)
	if typeof(result) != TYPE_DICTIONARY:
		return

	if not result.has("choices") or result["choices"].is_empty():
		return

	var choice: Dictionary = result["choices"][0]
	if not choice.has("delta"):
		return

	var delta: Variant = choice["delta"]

	if typeof(delta) != TYPE_DICTIONARY:
		return

	if delta.has("reasoning_content"):
		parent.on_ai_reasoning_content_generated(delta["reasoning_content"])
	elif delta.has("content"):
		parent.on_ai_content_generated(delta["content"])


func _stop_stream() -> void:
	set_process(false)
	if client.get_status() != HTTPClient.STATUS_DISCONNECTED:
		client.close()
