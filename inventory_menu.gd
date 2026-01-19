class_name InventoryMenu
extends CanvasLayer
## Displays unit inventory with equipment and item slots.

signal slot_selected(slot_type: String, slot_index: int)
signal cancelled

var panel: Panel
var content_container: VBoxContainer
var header_label: Label
var divider: HSeparator
var slot_buttons: Array[Button] = []
var selected_index: int = 0
var is_visible: bool = false

var panel_width: int = 200
var panel_padding: Vector2 = Vector2(8, 8)
var button_height: int = 32

var current_unit: Unit = null

func _ready() -> void:
	_create_ui()
	hide_menu()

func _create_ui() -> void:
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(panel_width, 0)
	add_child(panel)
	
	content_container = VBoxContainer.new()
	content_container.position = panel_padding
	content_container.add_theme_constant_override("separation", 4)
	panel.add_child(content_container)
	
	# Header
	header_label = Label.new()
	header_label.text = "INVENTORY"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.custom_minimum_size = Vector2(panel_width - panel_padding.x * 2, 30)
	content_container.add_child(header_label)

func show_inventory(screen_position: Vector2, unit: Unit) -> void:
	current_unit = unit
	_populate_inventory()
	
	await get_tree().process_frame
	
	var menu_height := content_container.size.y + panel_padding.y * 2
	var viewport_size := get_viewport().get_visible_rect().size
	
	var final_pos := screen_position
	if final_pos.x + panel_width > viewport_size.x:
		final_pos.x = viewport_size.x - panel_width
	if final_pos.y + menu_height > viewport_size.y:
		final_pos.y = viewport_size.y - menu_height
	
	panel.position = final_pos
	panel.size = Vector2(panel_width, menu_height)
	panel.visible = true
	is_visible = true
	
	selected_index = 0
	_update_focus()

func hide_menu() -> void:
	panel.visible = false
	is_visible = false
	current_unit = null
	_clear_slots()

func _populate_inventory() -> void:
	_clear_slots()
	
	# Equipment Slot 1 (equipped weapon)
	var equip1_text := ""
	var equip1_is_equipped := false
	if current_unit.data.equipped_weapon:
		equip1_text = current_unit.data.equipped_weapon.weapon_name
		equip1_is_equipped = true
	else:
		equip1_text = "[Empty]"
	_add_slot_button(equip1_text, "equipment", 0, equip1_is_equipped)
	
	# Equipment Slot 2 (inventory weapon)
	var equip2_text := ""
	if current_unit.data.inventory_weapon:
		equip2_text = current_unit.data.inventory_weapon.weapon_name
	else:
		equip2_text = "[Empty]"
	_add_slot_button(equip2_text, "equipment", 1, false)
	
	# Equipment Slot 3 (shield - only if can_equip_shield)
	if current_unit.data.can_equip_shield:
		var equip3_text := ""
		if current_unit.data.equipped_shield:
			equip3_text = current_unit.data.equipped_shield.weapon_name
		else:
			equip3_text = "[Empty]"
		_add_slot_button(equip3_text, "equipment", 2, current_unit.data.equipped_shield != null)
	
	# Divider
	divider = HSeparator.new()
	divider.custom_minimum_size = Vector2(panel_width - panel_padding.x * 2, 2)
	content_container.add_child(divider)
	
	# Item Slot 1
	var item1_text := current_unit.data.item_slot_1 if not current_unit.data.item_slot_1.is_empty() else "[Empty]"
	_add_slot_button(item1_text, "item", 0, false)
	
	# Item Slot 2
	var item2_text := current_unit.data.item_slot_2 if not current_unit.data.item_slot_2.is_empty() else "[Empty]"
	_add_slot_button(item2_text, "item", 1, false)

func _add_slot_button(text: String, slot_type: String, slot_index: int, is_equipped: bool = false) -> void:
	# Create container for icon + button
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	content_container.add_child(hbox)
	
	# Placeholder icon
	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(button_height, button_height)
	icon.color = Color(0.5, 0.5, 0.5, 1.0)  # Gray placeholder
	hbox.add_child(icon)
	
	# Check if this weapon can be equipped by the unit
	var can_equip := true
	var is_grayed := false
	if slot_type == "equipment" and current_unit:
		var weapon := current_unit.data.get_weapon_at_slot(slot_index)
		if weapon != null:
			can_equip = current_unit.data.can_equip_weapon_type(weapon)
			if not can_equip:
				is_grayed = true
	
	# Button
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(panel_width - panel_padding.x * 2 - button_height - 4, button_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.focus_mode = Control.FOCUS_ALL
	button.set_meta("slot_type", slot_type)
	button.set_meta("slot_index", slot_index)
	button.pressed.connect(_on_slot_pressed.bind(slot_type, slot_index))
	button.mouse_entered.connect(_on_button_mouse_entered.bind(slot_buttons.size()))
	
	# Gray out incompatible weapons
	if is_grayed:
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	
	# Apply equipped weapon highlight
	if is_equipped:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.2, 0.5, 1.0)  # Dark bluish violet
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
	
	hbox.add_child(button)
	slot_buttons.append(button)

func _clear_slots() -> void:
	slot_buttons.clear()
	
	# Remove all children except the header
	for child in content_container.get_children():
		if child != header_label:
			child.queue_free()
	
	divider = null

func _on_slot_pressed(slot_type: String, slot_index: int) -> void:
	slot_selected.emit(slot_type, slot_index)

func _on_button_mouse_entered(index: int) -> void:
	selected_index = index
	_update_focus()

func _update_focus() -> void:
	if slot_buttons.size() > 0 and selected_index >= 0 and selected_index < slot_buttons.size():
		slot_buttons[selected_index].grab_focus()

func _input(event: InputEvent) -> void:
	if not is_visible:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			selected_index = max(0, selected_index - 1)
			_update_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_S or event.keycode == KEY_DOWN:
			selected_index = min(slot_buttons.size() - 1, selected_index + 1)
			_update_focus()
			get_viewport().set_input_as_handled()
	
	if InputManager.is_confirm_pressed(event):
		if slot_buttons.size() > 0:
			var slot_type: String = slot_buttons[selected_index].get_meta("slot_type", "")
			var slot_index: int = slot_buttons[selected_index].get_meta("slot_index", 0)
			_on_slot_pressed(slot_type, slot_index)
		get_viewport().set_input_as_handled()
		return
	
	if InputManager.is_cancel_pressed(event):
		cancelled.emit()
		hide_menu()
		get_viewport().set_input_as_handled()
		return
