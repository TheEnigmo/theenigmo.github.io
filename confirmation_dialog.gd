class_name CustomConfirmationDialog
extends CanvasLayer
## Generic confirmation dialog with Yes/No options.

signal confirmed
signal cancelled

var panel: Panel
var message_label: Label
var button_container: HBoxContainer
var buttons: Array[Button] = []
var selected_index: int = 0
var is_visible: bool = false

func _ready() -> void:
	_create_ui()
	hide_dialog()

func _create_ui() -> void:
	# Panel
	panel = Panel.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.2, 0.2, 0.95)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.6, 0.6, 0.6)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.custom_minimum_size = Vector2(300, 120)
	add_child(panel)
	
	var content := VBoxContainer.new()
	content.position = Vector2(20, 20)
	content.size = Vector2(260, 80)
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)
	
	# Message label
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.custom_minimum_size = Vector2(260, 40)
	content.add_child(message_label)
	
	# Buttons
	button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	content.add_child(button_container)
	
	var yes_button := Button.new()
	yes_button.text = "Yes"
	yes_button.custom_minimum_size = Vector2(80, 40)
	yes_button.pressed.connect(_on_yes_pressed)
	yes_button.focus_mode = Control.FOCUS_ALL
	yes_button.mouse_entered.connect(func(): selected_index = 0; _update_focus())
	button_container.add_child(yes_button)
	buttons.append(yes_button)
	
	var no_button := Button.new()
	no_button.text = "No"
	no_button.custom_minimum_size = Vector2(80, 40)
	no_button.pressed.connect(_on_no_pressed)
	no_button.focus_mode = Control.FOCUS_ALL
	no_button.mouse_entered.connect(func(): selected_index = 1; _update_focus())
	button_container.add_child(no_button)
	buttons.append(no_button)

func show_dialog(message: String) -> void:
	message_label.text = message
	
	var viewport_size := get_viewport().get_visible_rect().size
	panel.position = Vector2(
		(viewport_size.x - panel.custom_minimum_size.x) / 2,
		(viewport_size.y - panel.custom_minimum_size.y) / 2
	)
	
	panel.visible = true
	is_visible = true
	selected_index = 1  # Default to "No"
	_update_focus()

func hide_dialog() -> void:
	panel.visible = false
	is_visible = false

func _on_yes_pressed() -> void:
	confirmed.emit()
	hide_dialog()

func _on_no_pressed() -> void:
	cancelled.emit()
	hide_dialog()

func _update_focus() -> void:
	if buttons.size() > 0:
		buttons[selected_index].grab_focus()

func _input(event: InputEvent) -> void:
	if not is_visible:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			selected_index = 0
			_update_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			selected_index = 1
			_update_focus()
			get_viewport().set_input_as_handled()
	
	if InputManager.is_confirm_pressed(event):
		if selected_index == 0:
			_on_yes_pressed()
		else:
			_on_no_pressed()
		get_viewport().set_input_as_handled()
	
	if InputManager.is_cancel_pressed(event):
		_on_no_pressed()
		get_viewport().set_input_as_handled()
