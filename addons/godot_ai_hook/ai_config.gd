class_name AiConfig
## AI Model configuration for Godot AI Hook.
## Configure your OpenAI-compatible API endpoint, key, and model here.

# 1. url: OpenAI Chat Completions compatible endpoint
static var url: String = "https://api.openai.com/v1/chat/completions"

# 2. api_key: Your API key (keep secret - never commit to public repos)
static var api_key: String = ""

# 3. model: The model name to use (refer to your provider's docs)
static var model: String = "gpt-4o-mini"

# 4. port: Port for streaming mode (HTTPS typically uses 443)
static var port: int = 443

## Text generation display settings:
## - append_interval_time: base interval between characters (seconds)
## - sentence_pause_extra: extra pause after sentence-ending punctuation (seconds)
## Set to 0 for instant display; increase for typewriter effect
static var append_interval_time: float = 0
static var sentence_pause_extra: float = 0
static var is_clean_before_reply: bool = true


static func get_stream_url_host() -> String:
	var clean: String = url.replace("https://", "").replace("http://", "")
	var split_pos: int = clean.find("/")
	return clean.substr(0, split_pos)


static func get_stream_url_path() -> String:
	var clean: String = url.replace("https://", "").replace("http://", "")
	var split_pos: int = clean.find("/")
	return clean.substr(split_pos)
