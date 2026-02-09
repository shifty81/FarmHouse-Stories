extends CanvasLayer
## HUD - Displays time, date, money, and energy to the player.

@onready var time_label = $MarginContainer/VBoxContainer/TimeLabel
@onready var date_label = $MarginContainer/VBoxContainer/DateLabel
@onready var money_label = $MarginContainer/VBoxContainer/MoneyLabel
@onready var energy_bar = $MarginContainer/VBoxContainer/EnergyBar


func _ready():
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.day_started.connect(_on_day_started)
	EventBus.player_money_changed.connect(_on_money_changed)
	EventBus.player_energy_changed.connect(_on_energy_changed)

	_update_display()


func _process(_delta):
	if time_label:
		time_label.text = Calendar.get_time_string()


func _update_display():
	if date_label:
		date_label.text = Calendar.get_date_string()
	if money_label:
		money_label.text = "Gold: %d" % EventBus.player_money
	if energy_bar:
		energy_bar.max_value = EventBus.player_max_energy
		energy_bar.value = EventBus.player_energy


func _on_hour_changed(_hour):
	_update_display()


func _on_day_started(_day, _season):
	_update_display()


func _on_money_changed(_money):
	_update_display()


func _on_energy_changed(_energy, _max_energy):
	_update_display()
