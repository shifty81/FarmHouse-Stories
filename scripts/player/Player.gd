extends CharacterBody2D
## Player - Handles player movement, animation, and interaction.
## Multiplayer-aware: only the owning peer processes input.

@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

var last_direction: Vector2 = Vector2.DOWN


func _ready():
	# Only enable camera for the local player
	if _is_local_player():
		camera.enabled = true
	else:
		camera.enabled = false


func _physics_process(delta):
	if not _is_local_player():
		return

	var input_direction = _get_input_direction()

	if input_direction != Vector2.ZERO:
		_apply_movement(input_direction, delta)
		last_direction = input_direction
		_update_animation("walk")
	else:
		_apply_friction(delta)
		_update_animation("idle")

	move_and_slide()


func _get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()


func _apply_movement(direction: Vector2, delta: float):
	velocity = velocity.move_toward(direction * speed, acceleration * delta)


func _apply_friction(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _update_animation(state: String):
	var direction_suffix = _get_direction_suffix()
	var animation_name = state + "_" + direction_suffix

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)


func _get_direction_suffix() -> String:
	if abs(last_direction.x) > abs(last_direction.y):
		return "right" if last_direction.x > 0 else "left"
	else:
		return "down" if last_direction.y > 0 else "up"


func _input(event):
	if not _is_local_player():
		return
	if event.is_action_pressed("interact"):
		_attempt_interaction()


func _attempt_interaction():
	var interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		var overlapping = interaction_area.get_overlapping_areas()
		for area in overlapping:
			if area.has_method("interact"):
				area.interact()
				return
	print("Nothing to interact with.")


func _is_local_player() -> bool:
	if not multiplayer.has_multiplayer_peer():
		return true
	return is_multiplayer_authority()
