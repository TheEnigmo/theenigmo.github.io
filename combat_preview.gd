class_name CombatPreview
extends CanvasLayer
## Displays combat preview before confirming attack.

signal attack_confirmed
signal attack_cancelled

var panel: Panel
var inner_panel: Panel
var button_container: HBoxContainer
var is_visible: bool = false

var attacker: Unit
var defender: Unit
var distance: int

var attacker_double_label: Label = null
var defender_double_label: Label = null

var buttons: Array[Button] = []
var selected_button_index: int = 0

var slide_tween: Tween = null
var panel_hidden_x: float = -400
var panel_visible_x: float = -6

var border_color: Color = Color(0.1, 0.1, 0.1)
var bg_color: Color = Color(0.78, 0.82, 0.65)
var text_color: Color = Color(0.1, 0.15, 0.1)
var highlight_green: Color = Color(0.2, 0.5, 0.2)
var highlight_red: Color = Color(0.6, 0.2, 0.2)
var divider_color: Color = Color(0.3, 0.35, 0.25)

var gameboy_font: Font = null

func _ready() -> void:
	_load_font()
	_create_panel()
	hide_preview()

func _load_font() -> void:
	var font_path := "res://assets/fonts/gameboy.ttf"
	if ResourceLoader.exists(font_path):
		gameboy_font = load(font_path)

func _create_panel() -> void:
	panel = Panel.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = border_color
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(0.05, 0.05, 0.05)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.custom_minimum_size = Vector2(380, 380)
	panel.size = Vector2(380, 380)
	add_child(panel)
	
	inner_panel = Panel.new()
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = bg_color
	inner_style.border_width_left = 3
	inner_style.border_width_right = 3
	inner_style.border_width_top = 3
	inner_style.border_width_bottom = 3
	inner_style.border_color = divider_color
	inner_panel.add_theme_stylebox_override("panel", inner_style)
	inner_panel.position = Vector2(6, 6)
	inner_panel.size = Vector2(368, 368)
	panel.add_child(inner_panel)
	
	button_container = HBoxContainer.new()
	button_container.position = Vector2(60, 320)
	button_container.add_theme_constant_override("separation", 40)
	inner_panel.add_child(button_container)
	
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.6, 0.65, 0.5)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.2, 0.25, 0.15)
	
	var confirm_button := Button.new()
	confirm_button.text = "ATTACK"
	confirm_button.custom_minimum_size = Vector2(100, 40)
	confirm_button.add_theme_stylebox_override("normal", btn_style)
	confirm_button.add_theme_stylebox_override("hover", btn_style)
	confirm_button.add_theme_stylebox_override("pressed", btn_style)
	confirm_button.add_theme_color_override("font_color", text_color)
	confirm_button.add_theme_font_size_override("font_size", 16)
	confirm_button.focus_mode = Control.FOCUS_ALL
	if gameboy_font:
		confirm_button.add_theme_font_override("font", gameboy_font)
	confirm_button.pressed.connect(_on_confirm_pressed)
	button_container.add_child(confirm_button)
	buttons.append(confirm_button)
	
	var cancel_button := Button.new()
	cancel_button.text = "CANCEL"
	cancel_button.custom_minimum_size = Vector2(100, 40)
	cancel_button.add_theme_stylebox_override("normal", btn_style)
	cancel_button.add_theme_stylebox_override("hover", btn_style)
	cancel_button.add_theme_stylebox_override("pressed", btn_style)
	cancel_button.add_theme_color_override("font_color", text_color)
	cancel_button.add_theme_font_size_override("font_size", 16)
	cancel_button.focus_mode = Control.FOCUS_ALL
	if gameboy_font:
		cancel_button.add_theme_font_override("font", gameboy_font)
	cancel_button.pressed.connect(_on_cancel_pressed)
	button_container.add_child(cancel_button)
	buttons.append(cancel_button)

func show_preview(attacker_unit: Unit, defender_unit: Unit, dist: int) -> void:
	attacker = attacker_unit
	defender = defender_unit
	distance = dist
	
	_clear_table()
	_populate_table()
	_position_panel_hidden()
	
	panel.visible = true
	is_visible = true
	
	selected_button_index = 0
	_update_button_focus()
	
	_slide_in()

func hide_preview() -> void:
	if slide_tween:
		slide_tween.kill()
	
	panel.visible = false
	is_visible = false
	attacker_double_label = null
	defender_double_label = null

func _slide_in() -> void:
	if slide_tween:
		slide_tween.kill()
	
	slide_tween = create_tween()
	slide_tween.tween_property(panel, "position:x", panel_visible_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _slide_out_and_hide(callback: Callable) -> void:
	if slide_tween:
		slide_tween.kill()
	
	slide_tween = create_tween()
	slide_tween.tween_property(panel, "position:x", panel_hidden_x, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	slide_tween.tween_callback(func():
		panel.visible = false
		is_visible = false
		attacker_double_label = null
		defender_double_label = null
		callback.call()
	)

func _position_panel_hidden() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	panel.position = Vector2(panel_hidden_x, (viewport_size.y - panel.size.y) / 2)

func _clear_table() -> void:
	for child in inner_panel.get_children():
		if child != button_container:
			child.queue_free()

func _populate_table() -> void:
	var can_counter := CombatCalculator.can_counterattack(defender.data, attacker.data, distance)
	
	var col1_x: float = 15
	var col2_x: float = 115
	var col3_x: float = 240
	var col_width: float = 120
	
	var row_height: float = 32
	var start_y: float = 15
	
	# Draw vertical dividers
	_draw_vertical_line(110)
	_draw_vertical_line(235)
	
	# Header row
	_add_text("", col1_x, start_y, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text("Attacker", col2_x, start_y, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text("Defender", col3_x, start_y, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	
	# Horizontal divider after header
	_draw_horizontal_line(start_y + row_height - 5)
	
	var row: int = 1
	
	# Name row
	_add_text("Name", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(attacker.data.unit_name, col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(defender.data.unit_name, col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# Class row
	var attacker_class_mod := CombatCalculator.get_class_matchup_modifier(attacker.data.class_id, defender.data.class_id)
	var defender_class_mod := CombatCalculator.get_class_matchup_modifier(defender.data.class_id, attacker.data.class_id)
	
	_add_text("Class", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(_get_class_name(attacker.data.class_id) + " Lv." + str(attacker.data.level), col2_x, start_y + row * row_height, col_width, _get_matchup_color(attacker_class_mod), HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(_get_class_name(defender.data.class_id) + " Lv." + str(defender.data.level), col3_x, start_y + row * row_height, col_width, _get_matchup_color(defender_class_mod), HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# Weapon row
	var attacker_weapon_name := attacker.data.equipped_weapon.weapon_name if attacker.data.equipped_weapon else "Unarmed"
	var defender_weapon_name := defender.data.equipped_weapon.weapon_name if defender.data.equipped_weapon else "Unarmed"
	_add_text("Weapon", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(attacker_weapon_name, col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(defender_weapon_name, col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# HP row
	_add_text("HP", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(str(attacker.data.hp_current) + "/" + str(attacker.data.hp_max), col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(str(defender.data.hp_current) + "/" + str(defender.data.hp_max), col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# Affinity row
	_add_text("Affinity", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(_get_element_name(attacker.data.affinity), col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(_get_element_name(defender.data.affinity), col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# Damage row
	var attacker_damage: int
	if attacker.data.uses_magic():
		attacker_damage = CombatCalculator.calculate_magic_damage(attacker.data, defender.data)
	else:
		attacker_damage = CombatCalculator.calculate_physical_damage(attacker.data, defender.data)
	
	var attacker_doubles := CombatCalculator.can_double_attack(attacker.data, defender.data)
	
	var defender_damage: int = 0
	var defender_doubles := false
	if can_counter:
		if defender.data.uses_magic():
			defender_damage = CombatCalculator.calculate_magic_damage(defender.data, attacker.data)
		else:
			defender_damage = CombatCalculator.calculate_physical_damage(defender.data, attacker.data)
		defender_doubles = CombatCalculator.can_double_attack(defender.data, attacker.data)
	
	_add_text("Damage", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_damage_text(str(attacker_damage), attacker_doubles, col2_x, start_y + row * row_height, col_width, true)
	_add_damage_text(str(defender_damage) if can_counter else "-", defender_doubles and can_counter, col3_x, start_y + row * row_height, col_width, false)
	row += 1
	
	# Hit Rate row
	var attacker_hit := CombatCalculator.calculate_hit_chance(attacker.data, defender.data)
	var defender_hit := CombatCalculator.calculate_hit_chance(defender.data, attacker.data) if can_counter else 0.0
	
	_add_text("Hit Rate", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(str(int(attacker_hit * 100)) + "%", col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(str(int(defender_hit * 100)) + "%" if can_counter else "-", col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	row += 1
	
	# Crit Rate row
	var attacker_crit := CombatCalculator.calculate_crit_chance(attacker.data)
	var defender_crit := CombatCalculator.calculate_crit_chance(defender.data) if can_counter else 0.0
	
	_add_text("Crit Rate", col1_x, start_y + row * row_height, 90, text_color, HORIZONTAL_ALIGNMENT_LEFT)
	_add_text(str(int(attacker_crit * 100)) + "%", col2_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	_add_text(str(int(defender_crit * 100)) + "%" if can_counter else "-", col3_x, start_y + row * row_height, col_width, text_color, HORIZONTAL_ALIGNMENT_CENTER)

func _add_text(text: String, x: float, y: float, width: float, color: Color, alignment: HorizontalAlignment) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(x, y)
	label.custom_minimum_size = Vector2(width, 25)
	label.size = Vector2(width, 25)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	if gameboy_font:
		label.add_theme_font_override("font", gameboy_font)
	label.horizontal_alignment = alignment
	inner_panel.add_child(label)

func _add_damage_text(damage_text: String, doubles: bool, x: float, y: float, width: float, is_attacker: bool) -> void:
	var hbox := HBoxContainer.new()
	hbox.position = Vector2(x, y)
	hbox.custom_minimum_size = Vector2(width, 25)
	hbox.size = Vector2(width, 25)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	inner_panel.add_child(hbox)
	
	var damage_label := Label.new()
	damage_label.text = damage_text
	damage_label.add_theme_color_override("font_color", text_color)
	damage_label.add_theme_font_size_override("font_size", 14)
	if gameboy_font:
		damage_label.add_theme_font_override("font", gameboy_font)
	hbox.add_child(damage_label)
	
	if doubles:
		var double_label := Label.new()
		double_label.text = " (x2)"
		double_label.add_theme_color_override("font_color", text_color)
		double_label.add_theme_font_size_override("font_size", 14)
		if gameboy_font:
			double_label.add_theme_font_override("font", gameboy_font)
		hbox.add_child(double_label)
		_start_flash_animation(double_label)
		
		if is_attacker:
			attacker_double_label = double_label
		else:
			defender_double_label = double_label

func _draw_vertical_line(x: float) -> void:
	var line := ColorRect.new()
	line.color = divider_color
	line.position = Vector2(x, 10)
	line.size = Vector2(2, 295)
	inner_panel.add_child(line)

func _draw_horizontal_line(y: float) -> void:
	var line := ColorRect.new()
	line.color = divider_color
	line.position = Vector2(10, y)
	line.size = Vector2(348, 2)
	inner_panel.add_child(line)

func _start_flash_animation(label: Label) -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(label, "modulate:a", 0.3, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(label, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_IN_OUT)

func _get_matchup_color(modifier: float) -> Color:
	if modifier > 0:
		return highlight_green
	elif modifier < 0:
		return highlight_red
	else:
		return text_color

func _get_class_name(class_id: Enums.ClassID) -> String:
	match class_id:
		Enums.ClassID.CAPTAIN: return "Captain"
		Enums.ClassID.DUELIST: return "Duelist"
		Enums.ClassID.LANCER: return "Lancer"
		Enums.ClassID.WARRIOR: return "Warrior"
		Enums.ClassID.ARCHER: return "Archer"
		Enums.ClassID.GUARDIAN: return "Guardian"
		Enums.ClassID.ROGUE: return "Rogue"
		Enums.ClassID.MAGE: return "Mage"
		Enums.ClassID.CLERIC: return "Cleric"
		Enums.ClassID.STRIKER: return "Striker"
	return "Unknown"

func _get_element_name(element: Enums.Element) -> String:
	match element:
		Enums.Element.NONE: return "None"
		Enums.Element.FIRE: return "Fire"
		Enums.Element.WATER: return "Water"
		Enums.Element.WIND: return "Wind"
		Enums.Element.EARTH: return "Earth"
		Enums.Element.LIGHTNING: return "Lightning"
		Enums.Element.HOLY: return "Holy"
		Enums.Element.DARK: return "Dark"
	return "Unknown"

func _on_confirm_pressed() -> void:
	_slide_out_and_hide(func(): attack_confirmed.emit())

func _on_cancel_pressed() -> void:
	_slide_out_and_hide(func(): attack_cancelled.emit())

func _input(event: InputEvent) -> void:
	if not is_visible:
		return
	
	# Keyboard navigation
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			selected_button_index = max(0, selected_button_index - 1)
			_update_button_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			selected_button_index = min(buttons.size() - 1, selected_button_index + 1)
			_update_button_focus()
			get_viewport().set_input_as_handled()
	
	# Confirm/Cancel
	if InputManager.is_confirm_pressed(event):
		if selected_button_index == 0:
			_on_confirm_pressed()
		else:
			_on_cancel_pressed()
		get_viewport().set_input_as_handled()
		return
	
	if InputManager.is_cancel_pressed(event):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
		return

func _update_button_focus() -> void:
	if buttons.size() > 0:
		buttons[selected_button_index].grab_focus()
