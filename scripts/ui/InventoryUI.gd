extends CanvasLayer
## InventoryUI - Visual inventory panel using TravelBook UI theme assets.
## Displays hotbar (9 slots) and bag (remaining slots) in a styled grid.

@onready var hotbar_grid = $CenterContainer/Panel/MarginContainer/VBoxContainer/HotbarGrid
@onready var inventory_grid = $CenterContainer/Panel/MarginContainer/VBoxContainer/InventoryGrid
@onready var close_button = $CenterContainer/Panel/MarginContainer/VBoxContainer/Header/CloseButton

var _slot_normal_tex = preload("res://gfx/ui/slots/slot_normal.png")
var _slot_selected_tex = preload("res://gfx/ui/slots/slot_selected.png")


func _ready():
	visible = false
	close_button.pressed.connect(_close)
	EventBus.inventory_opened.connect(_open)
	EventBus.inventory_closed.connect(_close)
	_build_slots()


func _input(event):
	if event.is_action_pressed("inventory"):
		if visible:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()


func _open():
	_refresh_slots()
	visible = true
	get_tree().paused = true


func _close():
	visible = false
	get_tree().paused = false


func _build_slots():
	# Build hotbar slots (first 9)
	for i in range(InventorySystem.MAX_HOTBAR_SLOTS):
		var slot = _create_slot_node(i)
		hotbar_grid.add_child(slot)

	# Build remaining inventory slots
	for i in range(InventorySystem.MAX_HOTBAR_SLOTS, InventorySystem.MAX_INVENTORY_SLOTS):
		var slot = _create_slot_node(i)
		inventory_grid.add_child(slot)


func _create_slot_node(index: int) -> TextureRect:
	var slot = TextureRect.new()
	slot.texture = _slot_normal_tex
	slot.custom_minimum_size = Vector2(32, 32)
	slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	slot.name = "Slot_%d" % index

	# Add a label for quantity display
	var qty_label = Label.new()
	qty_label.name = "Qty"
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	qty_label.anchors_preset = Control.PRESET_FULL_RECT
	qty_label.text = ""
	slot.add_child(qty_label)

	return slot


func _refresh_slots():
	# Update hotbar slots
	for i in range(InventorySystem.MAX_HOTBAR_SLOTS):
		var slot_node = hotbar_grid.get_child(i) as TextureRect
		_update_slot_display(slot_node, i)

	# Update bag slots
	var bag_start = InventorySystem.MAX_HOTBAR_SLOTS
	for i in range(bag_start, InventorySystem.MAX_INVENTORY_SLOTS):
		var child_idx = i - bag_start
		if child_idx < inventory_grid.get_child_count():
			var slot_node = inventory_grid.get_child(child_idx) as TextureRect
			_update_slot_display(slot_node, i)


func _update_slot_display(slot_node: TextureRect, slot_index: int):
	if not slot_node:
		return

	# Highlight selected hotbar slot
	if slot_index == InventorySystem.selected_hotbar_slot:
		slot_node.texture = _slot_selected_tex
	else:
		slot_node.texture = _slot_normal_tex

	# Update quantity label
	var qty_label = slot_node.get_node_or_null("Qty") as Label
	if qty_label:
		var slot_data = InventorySystem.get_slot(slot_index)
		if slot_data:
			var info = InventorySystem.get_item_info(slot_data.item_id)
			var display_name = info.get("name", slot_data.item_id) if info else slot_data.item_id
			slot_node.tooltip_text = "%s (x%d)" % [display_name, slot_data.quantity]
			if slot_data.quantity > 1:
				qty_label.text = str(slot_data.quantity)
			else:
				qty_label.text = ""
		else:
			slot_node.tooltip_text = ""
			qty_label.text = ""
