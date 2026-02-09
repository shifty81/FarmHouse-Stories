extends Node2D
## SpiritOrb - The companion spirit that guides the player through Echo Ridge Farm restoration.
## Grows brighter as the farm is cleared and restored.

enum State { DIM, SOFT, BRIGHT, RADIANT, GOLDEN }

@export var current_state: State = State.DIM
@export var dialogue_enabled: bool = true

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var dialogue_label: Label = $Label if has_node("Label") else null

## Dialogue by state
var dialogue_text: Dictionary = {
	State.DIM: [
		"The land... so tired. Help us... bloom again.",
		"Each stick you clear... brings warmth back."
	],
	State.SOFT: [
		"I can feel it! The earth remembers joy.",
		"You work like Elara did... with love."
	],
	State.BRIGHT: [
		"The Echo Tree stirs! Can you feel it?",
		"Nature Spirits are returning to the valley."
	],
	State.RADIANT: [
		"You've done it! The balance is restoring!",
		"I can teach you the old magics now."
	],
	State.GOLDEN: [
		"The land sings your name, friend.",
		"Elara would be so proud. You are the true inheritor."
	]
}


func _ready() -> void:
	update_appearance()

	# Connect to farm clearing signal
	if EventBus:
		EventBus.farm_cleared_percentage.connect(_on_farm_cleared)


func update_state(farm_clear_percentage: float) -> void:
	## Update spirit orb state based on farm clearing progress.
	var new_state: State = current_state

	if farm_clear_percentage >= 0.8:
		new_state = State.GOLDEN
	elif farm_clear_percentage >= 0.6:
		new_state = State.RADIANT
	elif farm_clear_percentage >= 0.4:
		new_state = State.BRIGHT
	elif farm_clear_percentage >= 0.2:
		new_state = State.SOFT
	else:
		new_state = State.DIM

	if new_state != current_state:
		current_state = new_state
		update_appearance()
		EventBus.spirit_orb_state_changed.emit(current_state)

		# Show dialogue on state change
		if dialogue_enabled:
			show_random_dialogue()


func update_appearance() -> void:
	## Update visual appearance based on current state.
	if not anim_sprite:
		return

	match current_state:
		State.DIM:
			anim_sprite.modulate = Color(0.3, 0.3, 0.3)
		State.SOFT:
			anim_sprite.modulate = Color(0.6, 0.6, 0.6)
		State.BRIGHT:
			anim_sprite.modulate = Color(1.0, 1.0, 1.0)
		State.RADIANT:
			anim_sprite.modulate = Color(1.2, 1.2, 1.0)
		State.GOLDEN:
			anim_sprite.modulate = Color(1.5, 1.4, 0.8)


func show_dialogue(text: String, duration: float = 3.0) -> void:
	## Display dialogue text for specified duration.
	if not dialogue_label:
		return

	dialogue_label.text = text
	dialogue_label.visible = true

	await get_tree().create_timer(duration).timeout

	dialogue_label.visible = false


func show_random_dialogue() -> void:
	## Show a random dialogue for the current state.
	if not dialogue_text.has(current_state):
		return

	var options: Array = dialogue_text[current_state]
	if options.is_empty():
		return

	var random_text: String = options[randi() % options.size()]
	show_dialogue(random_text)


func _on_farm_cleared(percent: float) -> void:
	## Handle farm clearing percentage update.
	update_state(percent)


func interact() -> void:
	## Called when player interacts with the spirit orb.
	show_random_dialogue()
