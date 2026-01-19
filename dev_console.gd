extends CanvasLayer
## God Mode developer panel with internal keyboard navigation.

var grid = null

# UI
var panel: Panel
var title_label: Label
var status_label: Label
var content_container: VBoxContainer
var console_visible: bool = false

# Navigation
var current_menu: String = "main"  # main, unit, grant, other, spawn_setup
var menu_buttons: Array[Control] = []
var selected_button_index: int = 0

# State management
enum State { IDLE, AWAITING_SPAWN_TILE, AWAITING_DESPAWN_UNIT, AWAITING_HEAL_UNIT, AWAITING_WARP_UNIT, AWAITING_WARP_TILE, AWAITING_GRANT_WEAPON_UNIT, AWAITING_GRANT_WEAPON_CHOICE, AWAITING_LEVEL_UP_UNIT }
var current_state: State = State.IDLE
var pending_unit_data: UnitData = null
var pending_warp_unit: Unit = null
var pending_grant_unit: Unit = null

# Spawn settings
var spawn_affiliation: Enums.UnitType = Enums.UnitType.PLAYER
var spawn_class: Enums.ClassID = Enums.ClassID.CAPTAIN
var spawn_tier: Enums.Tier = Enums.Tier.BASE
var spawn_level: int = 1

# Spawn UI references
var spawn_affiliation_option: OptionButton
var spawn_tier_option: OptionButton
var spawn_class_option: OptionButton
var spawn_level_option: OptionButton

# Panel positioning
var panel_hidden_x: float = -250
var panel_visible_x: float = 0

func _ready() -> void:
	ClassDatabase.initialize()
	_create_ui()
	hide_console()

func setup(grid_ref) -> void:
	grid = grid_ref

func _create_ui() -> void:
	# Main panel
	panel = Panel.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.15, 0.3, 0.9)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.3, 0.5)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.custom_minimum_size = Vector2(240, 600)
	panel.size = Vector2(240, 600)
	panel.position = Vector2(panel_hidden_x, 10)
	add_child(panel)
	
	# Title
	title_label = Label.new()
	title_label.text = "GOD MODE"
	title_label.position = Vector2(0, 10)
	title_label.size = Vector2(240, 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	panel.add_child(title_label)
	
	# Status label
	status_label = Label.new()
	status_label.text = ""
	status_label.position = Vector2(10, 45)
	status_label.size = Vector2(220, 20)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", Color.CYAN)
	panel.add_child(status_label)
	
	# Scrollable content container
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 70)
	scroll.size = Vector2(220, 520)
	panel.add_child(scroll)
	
	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content_container)
	
	_show_main_menu()

func _show_main_menu() -> void:
	current_menu = "main"
	_clear_content()
	_set_status("")
	
	_add_button("Unit Menu", func(): _show_unit_menu())
	_add_button("Grant Menu", func(): _show_grant_menu())
	_add_button("Other Menu", func(): _show_other_menu())

func _show_unit_menu() -> void:
	current_menu = "unit"
	_clear_content()
	
	_add_button("< Back", func(): _show_main_menu())
	_add_button("Spawn Unit", func(): _show_spawn_setup())
	_add_button("Despawn Unit", func(): _start_despawn())
	_add_button("Heal Unit", func(): _start_heal())
	_add_button("Level Up Unit", func(): _start_level_up())
	_add_button("Revive Unit [TODO]", func(): _set_status("Not implemented"))
	_add_button("Edit Stats [TODO]", func(): _set_status("Not implemented"))
	_add_button("Edit Level [TODO]", func(): _set_status("Not implemented"))
	_add_button("Apply Status [TODO]", func(): _set_status("Not implemented"))
	_add_button("Warp Unit", func(): _start_warp())

func _show_grant_menu() -> void:
	current_menu = "grant"
	_clear_content()
	
	_add_button("< Back", func(): _show_main_menu())
	_add_button("Grant Weapon", func(): _start_grant_weapon())
	_add_button("Grant Item [TODO]", func(): _set_status("Not implemented"))
	_add_button("Grant Esotera [TODO]", func(): _set_status("Not implemented"))
	_add_button("Grant Gold [TODO]", func(): _set_status("Not implemented"))

func _show_other_menu() -> void:
	current_menu = "other"
	_clear_content()
	
	_add_button("< Back", func(): _show_main_menu())
	_add_button("Reset Floor [TODO]", func(): _set_status("Not implemented"))
	_add_button("Adjust Speed [TODO]", func(): _set_status("Not implemented"))
	_add_button("Sound Test [TODO]", func(): _set_status("Not implemented"))

func _show_spawn_setup() -> void:
	current_menu = "spawn_setup"
	_clear_content()
	
	# 1. Affiliation
	var affil_label := Label.new()
	affil_label.text = "Affiliation:"
	content_container.add_child(affil_label)
	spawn_affiliation_option = OptionButton.new()
	spawn_affiliation_option.add_item("Player", 0)
	spawn_affiliation_option.add_item("Enemy", 1)
	content_container.add_child(spawn_affiliation_option)
	
	# 2. Tier
	var tier_label := Label.new()
	tier_label.text = "Tier:"
	content_container.add_child(tier_label)
	spawn_tier_option = OptionButton.new()
	spawn_tier_option.add_item("Base", Enums.Tier.BASE)
	spawn_tier_option.add_item("Ascension", Enums.Tier.ASCENSION)
	spawn_tier_option.add_item("Mastery", Enums.Tier.MASTERY)
	spawn_tier_option.item_selected.connect(_on_tier_changed)
	content_container.add_child(spawn_tier_option)
	
	# 3. Class
	var class_label := Label.new()
	class_label.text = "Class:"
	content_container.add_child(class_label)
	spawn_class_option = OptionButton.new()
	content_container.add_child(spawn_class_option)
	_populate_class_options(Enums.Tier.BASE)
	
	# 4. Level
	var level_label := Label.new()
	level_label.text = "Level:"
	content_container.add_child(level_label)
	spawn_level_option = OptionButton.new()
	content_container.add_child(spawn_level_option)
	_populate_level_options(Enums.Tier.BASE)

	# 5. Buttons
	_add_button("Confirm", func(): _confirm_spawn())
	_add_button("Cancel", func(): _show_unit_menu())

func _populate_class_options(tier: Enums.Tier) -> void:
	spawn_class_option.clear()
	
	match tier:
		Enums.Tier.BASE:
			spawn_class_option.add_item("Captain", Enums.ClassID.CAPTAIN)
			spawn_class_option.add_item("Duelist", Enums.ClassID.DUELIST)
			spawn_class_option.add_item("Lancer", Enums.ClassID.LANCER)
			spawn_class_option.add_item("Warrior", Enums.ClassID.WARRIOR)
			spawn_class_option.add_item("Archer", Enums.ClassID.ARCHER)
			spawn_class_option.add_item("Guardian", Enums.ClassID.GUARDIAN)
			spawn_class_option.add_item("Rogue", Enums.ClassID.ROGUE)
			spawn_class_option.add_item("Mage", Enums.ClassID.MAGE)
			spawn_class_option.add_item("Cleric", Enums.ClassID.CLERIC)
			spawn_class_option.add_item("Striker", Enums.ClassID.STRIKER)
		Enums.Tier.ASCENSION:
			spawn_class_option.add_item("Vanguard", Enums.ClassID.VANGUARD)
			spawn_class_option.add_item("Swordmaster", Enums.ClassID.SWORDMASTER)
			spawn_class_option.add_item("Sentinel", Enums.ClassID.SENTINEL)
			spawn_class_option.add_item("Raider", Enums.ClassID.RAIDER)
			spawn_class_option.add_item("Sniper", Enums.ClassID.SNIPER)
			spawn_class_option.add_item("Bastion", Enums.ClassID.BASTION)
			spawn_class_option.add_item("Assassin", Enums.ClassID.ASSASSIN)
			spawn_class_option.add_item("Sage", Enums.ClassID.SAGE)
			spawn_class_option.add_item("Bishop", Enums.ClassID.BISHOP)
			spawn_class_option.add_item("Pugilist", Enums.ClassID.PUGILIST)
		Enums.Tier.MASTERY:
			spawn_class_option.add_item("Hero", Enums.ClassID.HERO)
			spawn_class_option.add_item("Kensei", Enums.ClassID.KENSEI)
			spawn_class_option.add_item("Dragoon", Enums.ClassID.DRAGOON)
			spawn_class_option.add_item("Berserker", Enums.ClassID.BERSERKER)
			spawn_class_option.add_item("Hunter", Enums.ClassID.HUNTER)
			spawn_class_option.add_item("Phalanx", Enums.ClassID.PHALANX)
			spawn_class_option.add_item("Shinobi", Enums.ClassID.SHINOBI)
			spawn_class_option.add_item("Summoner", Enums.ClassID.SUMMONER)
			spawn_class_option.add_item("Paladin", Enums.ClassID.PALADIN)
			spawn_class_option.add_item("Monk", Enums.ClassID.MONK)

# New helper function
func _populate_level_options(tier: Enums.Tier) -> void:
	spawn_level_option.clear()
	var max_level = 20 if tier == Enums.Tier.MASTERY else 10
	for i in range(1, max_level + 1):
		spawn_level_option.add_item(str(i), i)

func _on_tier_changed(idx: int) -> void:
	var tier: Enums.Tier = spawn_tier_option.get_item_id(idx) as Enums.Tier
	_populate_class_options(tier)
	_populate_level_options(tier)

func _confirm_spawn() -> void:
	spawn_affiliation = (Enums.UnitType.PLAYER if spawn_affiliation_option.selected == 0 else Enums.UnitType.ENEMY) as Enums.UnitType
	spawn_class = spawn_class_option.get_item_id(spawn_class_option.selected) as Enums.ClassID
	spawn_tier = spawn_tier_option.get_item_id(spawn_tier_option.selected) as Enums.Tier
	spawn_level = spawn_level_option.get_selected_id()
	
	current_state = State.AWAITING_SPAWN_TILE
	_set_status("Choose a spawn tile")

func _start_despawn() -> void:
	current_state = State.AWAITING_DESPAWN_UNIT
	_set_status("Select unit to despawn")

func _start_heal() -> void:
	current_state = State.AWAITING_HEAL_UNIT
	_set_status("Select unit to heal")

func _start_level_up() -> void:
	current_state = State.AWAITING_LEVEL_UP_UNIT
	_set_status("Select unit to level up")

func _start_warp() -> void:
	current_state = State.AWAITING_WARP_UNIT
	_set_status("Select unit to warp")

func _start_grant_weapon() -> void:
	current_state = State.AWAITING_GRANT_WEAPON_UNIT
	_set_status("Select unit to grant weapon")

func _show_weapon_selection() -> void:
	current_menu = "weapon_selection"
	_clear_content()
	
	_add_button("< Cancel", func(): _cancel_grant_weapon())
	
	# Get all weapons from database
	var weapon_names := WeaponDatabase.weapons.keys()
	weapon_names.sort()
	
	for weapon_name in weapon_names:
		var btn := Button.new()
		btn.text = weapon_name
		btn.custom_minimum_size = Vector2(0, 35)
		btn.pressed.connect(_grant_weapon_to_unit.bind(weapon_name))
		content_container.add_child(btn)
		menu_buttons.append(btn)

func _add_weapon_button(weapon_name: String) -> void:
	_add_button(weapon_name, func(): _grant_weapon_to_unit(weapon_name))

func _grant_weapon_to_unit(weapon_name: String) -> void:
	if not pending_grant_unit:
		return
	
	var weapon := WeaponDatabase.get_weapon(weapon_name)
	if not weapon:
		_set_status("Weapon not found!")
		return
	
	# Grant to inventory if equipped slot is full, otherwise equip
	if pending_grant_unit.data.equipped_weapon == null:
		pending_grant_unit.data.equipped_weapon = weapon
		_set_status("Equipped %s" % weapon_name)
	elif pending_grant_unit.data.inventory_weapon == null:
		pending_grant_unit.data.inventory_weapon = weapon
		_set_status("Added %s to inventory" % weapon_name)
	else:
		_set_status("Inventory full!")
	
	pending_grant_unit = null
	current_state = State.IDLE
	_show_grant_menu()

func _cancel_grant_weapon() -> void:
	pending_grant_unit = null
	current_state = State.IDLE
	_show_grant_menu()

func _add_button(text: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 35)
	btn.pressed.connect(callback)
	content_container.add_child(btn)
	menu_buttons.append(btn)

func _clear_content() -> void:
	# Clear the navigation list first to prevent the input loop from seeing dead buttons
	menu_buttons.clear()
	selected_button_index = 0
	
	for child in content_container.get_children():
		child.queue_free()

func _set_status(text: String) -> void:
	status_label.text = text

func _show_level_up_visual(unit: Unit, new_level: int, evolved: bool, new_class: String) -> void:
	# Async wrapper to call combat manager's visual feedback
	if grid.combat_manager:
		grid.combat_manager._show_level_up(unit, new_level, evolved, new_class)

func handle_tile_click(coord: Vector2i) -> bool:
	match current_state:
		State.AWAITING_SPAWN_TILE:
			if grid.is_tile_empty(coord):
				pending_unit_data = _create_unit_data(spawn_affiliation, spawn_class, spawn_tier, spawn_level, coord)
				var unit: Unit = grid.spawn_unit(pending_unit_data)
				if spawn_affiliation == Enums.UnitType.PLAYER:
					grid.turn_manager.player_units.append(unit)
				else:
					grid.turn_manager.enemy_units.append(unit)
				_set_status("Unit spawned")
				current_state = State.IDLE
				_show_unit_menu()
				return true
			else:
				_set_status("Tile occupied!")
				return true
		
		State.AWAITING_DESPAWN_UNIT:
			var tile: Tile = grid.get_tile(coord)
			if tile and tile.occupant:
				grid._on_unit_died(tile.occupant)
				_set_status("Unit despawned")
				current_state = State.IDLE
				_show_unit_menu()
				return true
			else:
				_set_status("No unit here")
				return true
		
		State.AWAITING_HEAL_UNIT:
			var tile: Tile = grid.get_tile(coord)
			if tile and tile.occupant:
				tile.occupant.data.hp_current = tile.occupant.data.hp_max
				_set_status("Unit healed")
				current_state = State.IDLE
				_show_unit_menu()
				return true
			else:
				_set_status("No unit here")
				return true
		
		State.AWAITING_LEVEL_UP_UNIT:
			var tile: Tile = grid.get_tile(coord)
			if tile and tile.occupant:
				var unit: Unit = tile.occupant
				# Give enough XP to reach next level
				var xp_needed: int = unit.data.xp_to_next_level - unit.data.xp_current
				if xp_needed > 0:
					var result := ExperienceManager.add_xp(unit.data, xp_needed)
					if result["leveled_up"]:
						_set_status("Unit leveled up to %d" % result["new_level"])
						# Trigger visual feedback asynchronously
						if grid.combat_manager:
							_show_level_up_visual(unit, result["new_level"], result.get("evolved", false), result.get("new_class", ""))
						if result["evolved"]:
							_set_status("Unit evolved to %s!" % result["new_class"])
					else:
						_set_status("Unit at max level")
				else:
					_set_status("Unit at max level")
				current_state = State.IDLE
				_show_unit_menu()
				return true
			else:
				_set_status("No unit here")
				return true
		
		State.AWAITING_WARP_UNIT:
			var tile: Tile = grid.get_tile(coord)
			if tile and tile.occupant:
				pending_warp_unit = tile.occupant
				current_state = State.AWAITING_WARP_TILE
				_set_status("Warp to which tile?")
				return true
			else:
				_set_status("No unit here")
				return true
		
		State.AWAITING_WARP_TILE:
			if grid.is_tile_empty(coord):
				var old_tile: Tile = grid.get_tile(pending_warp_unit.data.coordinate)
				old_tile.clear_occupant()
				var new_tile: Tile = grid.get_tile(coord)
				new_tile.set_occupant(pending_warp_unit, pending_warp_unit.data.unit_type)
				pending_warp_unit.move_to(coord)
				_set_status("Unit warped")
				current_state = State.IDLE
				pending_warp_unit = null
				_show_unit_menu()
				return true
			else:
				_set_status("Tile occupied!")
				return true
		
		State.AWAITING_GRANT_WEAPON_UNIT:
			var tile: Tile = grid.get_tile(coord)
			if tile and tile.occupant:
				pending_grant_unit = tile.occupant
				current_state = State.AWAITING_GRANT_WEAPON_CHOICE
				_show_weapon_selection()
				return true
			else:
				_set_status("No unit here")
				return true
	
	return false

func _create_unit_data(unit_type: Enums.UnitType, class_id: Enums.ClassID, tier: Enums.Tier, level: int, coord: Vector2i) -> UnitData:
	var data := UnitData.new()
	data.unit_type = unit_type
	data.class_id = class_id
	data.tier = tier
	data.level = level
	data.coordinate = coord
	data.affinity = Enums.Element.NONE
	data.unit_name = "Dev " + ClassDatabase.get_class_name(class_id)
	
	# Get stats from StatsDatabase
	var stats := StatsDatabase.get_stats_for_level(class_id, level)
	data.hp_max = stats.get("hp", 25)
	data.atk = stats.get("atk", 15)
	data.def = stats.get("def", 10)
	data.spd = stats.get("spd", 15)
	data.int_stat = stats.get("int", 10)
	data.res = stats.get("res", 10)
	data.luk = stats.get("luk", 15)
	data.hp_current = data.hp_max
	
	# Initialize XP
	data.xp_current = 0
	data.xp_to_next_level = ExperienceManager.get_xp_required_for_level(tier, level + 1)
	
	# Assign appropriate weapon based on class
	var default_weapon: WeaponData = _get_default_weapon_for_class(class_id)
	data.equipped_weapon = default_weapon
	
	return data

func _get_default_weapon_for_class(class_id: Enums.ClassID) -> WeaponData:
	var proficiencies: Array = ClassDatabase.classes.get(class_id, {}).get("proficiencies", [])
	
	if proficiencies.is_empty():
		return null
	
	# Map first proficiency to training weapon
	match proficiencies[0]:
		Enums.WeaponType.LIGHT_SWORD:
			return WeaponDatabase.get_weapon.call("Training Sword")
		Enums.WeaponType.LIGHT_AXE:
			return WeaponDatabase.get_weapon.call("Training Axe")
		Enums.WeaponType.SHORTBOW:
			return WeaponDatabase.get_weapon.call("Training Shortbow")
		Enums.WeaponType.SPEAR:
			return WeaponDatabase.get_weapon.call("Training Spear")
		Enums.WeaponType.DAGGER:
			return WeaponDatabase.get_weapon.call("Training Dagger")
		Enums.WeaponType.WAND:
			return WeaponDatabase.get_weapon.call("Training Wand")
		Enums.WeaponType.FIST:
			return WeaponDatabase.get_weapon.call("Training Fist")
		_:
			return WeaponDatabase.get_weapon.call("Training Sword")

func show_console() -> void:
	panel.visible = true
	console_visible = true
	_slide_in()

func hide_console() -> void:
	console_visible = false  # Add this line
	current_state = State.IDLE
	pending_unit_data = null
	pending_warp_unit = null
	pending_grant_unit = null
	_set_status("")
	_slide_out()

func toggle_console() -> void:
	if console_visible:
		hide_console()
	else:
		show_console()

func _slide_in() -> void:
	var tween := create_tween()
	tween.tween_property(panel, "position:x", panel_visible_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _slide_out() -> void:
	var tween := create_tween()
	tween.tween_property(panel, "position:x", panel_hidden_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	panel.visible = false

func handle_cancel() -> void:
	if current_state != State.IDLE:
		current_state = State.IDLE
		pending_unit_data = null
		pending_warp_unit = null
		pending_grant_unit = null
		_set_status("Cancelled")
		
		# Return to appropriate menu based on what was being done
		if current_menu == "weapon_selection":
			_show_grant_menu()
		else:
			_show_unit_menu()
	elif current_menu != "main":
		_show_main_menu()

func _input(event: InputEvent) -> void:
	if not console_visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_QUOTELEFT:
				toggle_console()
				get_viewport().set_input_as_handled()
		return
	
	# Only handle backtick key for closing console
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_QUOTELEFT:
			toggle_console()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_X:
			handle_cancel()
			get_viewport().set_input_as_handled()
