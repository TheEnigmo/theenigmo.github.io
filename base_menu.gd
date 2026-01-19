class_name BaseMenu
extends CanvasLayer
## Base class for all menu UIs. Handles navigation, button management, and positioning.

signal option_selected(option_id: String)
signal cancelled

var panel: Panel
var content_container: VBoxContainer
var buttons: Array[Button] = []
var selected_index: int = 0
var is_visible: bool = false

# Override these in child classes
var panel_width: int = 120
var panel_padding: Vector2 = Vector2(8, 8)
var button_height: int = 32
var button_spacing: int = 0

func _ready() -> void:
	_create_base_ui()
	hide_menu()

func _create_base_ui() -> void:
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(panel_width, 0)
	add_child(panel)
	
	content_container = VBoxContainer.new()
	content_container.position = panel_padding
	content_container.add_theme_constant_override("separation", button_spacing)
	panel.add_child(content_container)

func add_option(text: String, option_id: String, enabled: bool = true) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(panel_width - panel_padding.x * 2, button_height)
	button.disabled = not enabled
	button.set_meta("option_id", option_id)
	button.pressed.connect(_on_option_pressed.bind(option_id))
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_entered.connect(_on_button_mouse_entered.bind(buttons.size()))
	content_container.add_child(button)
	buttons.append(button)

func show_menu(screen_position: Vector2 = Vector2.ZERO) -> void:
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
	_clear_options()

func _clear_options() -> void:
	for button in buttons:
		button.queue_free()
	buttons.clear()

func _on_option_pressed(option_id: String) -> void:
	option_selected.emit(option_id)
	hide_menu()

func _on_button_mouse_entered(index: int) -> void:
	selected_index = index
	_update_focus()

func _update_focus() -> void:
	if buttons.size() > 0 and selected_index >= 0 and selected_index < buttons.size():
		buttons[selected_index].grab_focus()

func _input(event: InputEvent) -> void:
	if not is_visible:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			selected_index = max(0, selected_index - 1)
			_update_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_S or event.keycode == KEY_DOWN:
			selected_index = min(buttons.size() - 1, selected_index + 1)
			_update_focus()
			get_viewport().set_input_as_handled()
	
	if InputManager.is_confirm_pressed(event):
		if buttons.size() > 0:
			var option_id: String = buttons[selected_index].get_meta("option_id", "")
			if option_id != "":
				_on_option_pressed(option_id)
		get_viewport().set_input_as_handled()
		return
	
	if InputManager.is_cancel_pressed(event):
		cancelled.emit()
		hide_menu()
		get_viewport().set_input_as_handled()
		return
