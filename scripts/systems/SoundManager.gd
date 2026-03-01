extends Node
## SoundManager - Manages background music and sound effects.
## Supports BGM crossfade and SFX pooling.

const SFX_POOL_SIZE: int = 8
const FADE_DURATION: float = 1.0
const MIN_VOLUME_DB: float = -80.0

var _bgm_player_a: AudioStreamPlayer
var _bgm_player_b: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _current_bgm: String = ""
var _fading: bool = false
var _fade_time: float = 0.0
var _fade_from: AudioStreamPlayer
var _fade_to: AudioStreamPlayer


func _ready() -> void:
	_bgm_player_a = AudioStreamPlayer.new()
	_bgm_player_a.bus = "Music"
	add_child(_bgm_player_a)

	_bgm_player_b = AudioStreamPlayer.new()
	_bgm_player_b.bus = "Music"
	_bgm_player_b.volume_db = MIN_VOLUME_DB
	add_child(_bgm_player_b)

	for i: int in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)


func _process(delta: float) -> void:
	if not _fading:
		return
	_fade_time += delta
	var t: float = clampf(_fade_time / FADE_DURATION, 0.0, 1.0)
	if _fade_from:
		_fade_from.volume_db = lerpf(0.0, MIN_VOLUME_DB, t)
	if _fade_to:
		_fade_to.volume_db = lerpf(MIN_VOLUME_DB, 0.0, t)
	if t >= 1.0:
		_fading = false
		if _fade_from:
			_fade_from.stop()
			_fade_from.volume_db = 0.0


func play_bgm(stream: AudioStream, track_id: String = "") -> void:
	if track_id != "" and track_id == _current_bgm:
		return
	_current_bgm = track_id

	var next: AudioStreamPlayer
	if _bgm_player_a.playing:
		next = _bgm_player_b
		_fade_from = _bgm_player_a
	else:
		next = _bgm_player_a
		_fade_from = _bgm_player_b

	next.stream = stream
	next.volume_db = MIN_VOLUME_DB
	next.play()
	_fade_to = next
	_fade_time = 0.0
	_fading = true
	EventBus.bgm_changed.emit(track_id)


func stop_bgm() -> void:
	_current_bgm = ""
	_fading = false
	_bgm_player_a.stop()
	_bgm_player_b.stop()


func play_sfx(stream: AudioStream, sfx_id: String = "") -> void:
	var player: AudioStreamPlayer = _sfx_pool[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.play()
	if sfx_id != "":
		EventBus.sfx_played.emit(sfx_id)


func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var db: float = linear_to_db(clampf(linear, 0.0, 1.0))
	AudioServer.set_bus_volume_db(idx, db)
	EventBus.volume_changed.emit(bus_name, linear)


func get_bus_volume(bus_name: String) -> float:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


func get_current_bgm() -> String:
	return _current_bgm
