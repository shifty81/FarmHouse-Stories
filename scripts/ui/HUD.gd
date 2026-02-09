extends CanvasLayer
## HUD - Displays time, date, money, and energy to the player.
## Uses TravelBook UI theme assets for styled display.

@onready var time_label = $MarginContainer/VBoxContainer/TimeLabel
@onready var date_label = $MarginContainer/VBoxContainer/DateLabel
@onready var money_label = $MarginContainer/VBoxContainer/MoneyRow/MoneyLabel
@onready var energy_bar = $MarginContainer/VBoxContainer/EnergyRow/EnergyBar
@onready var energy_icon = $MarginContainer/VBoxContainer/EnergyRow/EnergyIcon

var _energy_icon_full = preload("res://gfx/ui/icons/icon_energy_full.png")
var _energy_icon_mid = preload("res://gfx/ui/icons/icon_energy_mid.png")
var _energy_icon_low = preload("res://gfx/ui/icons/icon_energy_low.png")


func _ready():
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.day_started.connect(_on_day_started)
	EventBus.player_money_changed.connect(_on_money_changed)
	EventBus.player_energy_changed.connect(_on_energy_changed)

	_update_display()


func _update_display():
	if time_label:
		time_label.text = Calendar.get_time_string()
	if date_label:
		date_label.text = Calendar.get_date_string()
	if money_label:
		money_label.text = "%d" % EventBus.player_money
	if energy_bar:
		energy_bar.max_value = EventBus.player_max_energy
		energy_bar.value = EventBus.player_energy
		_update_energy_icon()


func _update_energy_icon():
	if not energy_icon:
		return
	var ratio = float(EventBus.player_energy) / float(max(EventBus.player_max_energy, 1))
	if ratio > 0.5:
		energy_icon.texture = _energy_icon_full
	elif ratio > 0.2:
		energy_icon.texture = _energy_icon_mid
	else:
		energy_icon.texture = _energy_icon_low


func _on_hour_changed(_hour):
	_update_display()


func _on_day_started(_day, _season):
	_update_display()


func _on_money_changed(_money):
	_update_display()


func _on_energy_changed(_energy, _max_energy):
	_update_display()
