extends Control

## Test panel for Godot AI Hook - validates API connectivity and display behavior.

@onready var model_input: LineEdit = $VBoxContainer/GridContainer/LineEdit
@onready var url_input: LineEdit = $VBoxContainer/GridContainer/LineEdit2
@onready var api_key_input: LineEdit = $VBoxContainer/GridContainer/LineEdit3

@onready var connect_btn: Button = $VBoxContainer/GridContainer/Button
@onready var test_chat_btn: Button = $VBoxContainer/GridContainer/Button2
@onready var connect_state_label: Label = $VBoxContainer/GridContainer/Label5

@onready var log_view: TextEdit = $VBoxContainer/TextEdit

@onready var test1: LineEdit = $VBoxContainer/ScrollContainer/GridContainer2/LineEdit
@onready var test1_ai: AiManage = $VBoxContainer/ScrollContainer/GridContainer2/LineEdit/AiManage

@export var interruption_time: float = 4.0
@export var protect_time: float = 2.0
var _http: HTTPRequest = null


func _ready() -> void:
	connect_btn.pressed.connect(_on_connect_test_pressed)
	test_chat_btn.pressed.connect(_on_test_chat_pressed)
	_load_from_config()
	_log("[Init] AI Connection Test Ready")


func _load_from_config() -> void:
	model_input.text = AiConfig.model
	url_input.text = AiConfig.url
	api_key_input.text = AiConfig.api_key


func _apply_temp_config() -> bool:
	var model_text := model_input.text.strip_edges()
	var url_text := url_input.text.strip_edges()
	var key_text := api_key_input.text.strip_edges()

	if model_text.is_empty() or url_text.is_empty() or key_text.is_empty():
		_log("[Error] Model / URL / API Key must not be empty")
		return false

	AiConfig.model = model_text
	AiConfig.url = url_text
	AiConfig.api_key = key_text
	return true


func _on_connect_test_pressed() -> void:
	_clear_log()
	connect_state_label.text = "Testing..."

	if not _apply_temp_config():
		connect_state_label.text = "Config error"
		return

	_log("[Test] Start connectivity test")

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_connect_result)

	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % AiConfig.api_key
	]

	var body := {
		"model": AiConfig.model,
		"messages": [
			{"role": "user", "content": "ping"}
		]
	}

	var err := _http.request(
		AiConfig.url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if err != OK:
		_log("[Error] Failed to start HTTP request: " + str(err))
		connect_state_label.text = "Start failed"


func _on_connect_result(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_log("[Fail] Network layer failed, result=" + str(result))
		connect_state_label.text = "Network failed"
		_safe_free_http()
		return

	_log("[HTTP] response_code=" + str(response_code))

	if response_code == 200:
		_log("[OK] Connection succeeded, API is available")
		connect_state_label.text = "Connected"
	else:
		_log("[Fail] Connection failed, response body:")
		_log(body.get_string_from_utf8())
		connect_state_label.text = "Connection failed"

	_safe_free_http()


func _on_test_chat_pressed() -> void:
	_log("\n[Test] Start effect test (AiManage)")

	if not _apply_temp_config():
		return

	var prompt := "This is a connectivity and display test, please reply briefly."
	test1_ai.say(prompt)


func _safe_free_http() -> void:
	if _http and is_instance_valid(_http):
		_http.queue_free()
	_http = null


func _log(text: String) -> void:
	log_view.text += text + "\n"


func _clear_log() -> void:
	log_view.text = ""
