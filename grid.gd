class_name Grid
extends Node2D
## Manages the 9x9 combat grid, tile access, and pathfinding.

var tiles: Dictionary = {}
var units: Array[Unit] = []
var tile_visuals: Dictionary = {}
var selected_unit: Unit = null
var path_visual: PathVisual = null
var turn_manager: TurnManager = null
var phase_banner: PhaseBanner = null
var action_menu: ActionMenu = null
var just_selected: bool = false
var combat_manager: CombatManager = null
var is_selecting_target: bool = false
var valid_targets: Array[Unit] = []
var pending_move_coord: Vector2i
var is_awaiting_action: bool = false
var player_action_menu: PlayerActionMenu = null
var inventory_menu: InventoryMenu = null
var combat_preview: CombatPreview = null
var pending_target: Unit = null
var hovered_enemy: Unit = null
var hover_banner: CanvasLayer
var inspect_screen: CanvasLayer
var target_selection_banner: CanvasLayer
var grid_cursor: GridCursor = null
var cursor_coord: Vector2i = Vector2i(4, 4)  # Start at center
var pending_inventory_slot_type: String = ""
var pending_inventory_slot_index: int = 0
var item_slot_action_menu = null
var confirmation_dialog = null
var weapon_selection_menu = null
var is_selecting_spell: bool = false
var is_casting_spell: bool = false
var selected_spell: SpellData = null

const UnitScene: PackedScene = preload("res://scenes/unit.tscn")

# Script preloads for new classes
const ItemSlotActionMenuScript = preload("res://scripts/item_slot_action_menu.gd")
const CustomConfirmationDialogScript = preload("res://scripts/confirmation_dialog.gd")
const WeaponSelectionMenuScript = preload("res://scripts/weapon_selection_menu.gd")

func _ready() -> void:
	ClassDatabase.initialize()
	WeaponDatabase.initialize()
	EsoteraDatabase.initialize()
	ItemDatabase.initialize()
	SpellDatabase.initialize()
	StatsDatabase.initialize()
	_initialize_tiles()
	_draw_grid()
	path_visual = PathVisual.new()
	add_child(path_visual)
	_spawn_test_unit()
	
	combat_manager = CombatManager.new()
	add_child(combat_manager)
	combat_manager.setup(self)
	combat_manager.combat_finished.connect(_on_combat_finished)
	combat_manager.unit_died.connect(_on_unit_died)
	combat_manager.damage_dealt.connect(_on_damage_dealt)
	
	turn_manager = TurnManager.new()
	add_child(turn_manager)
	turn_manager.set_references(self, combat_manager)
	turn_manager.setup(units)
	
	phase_banner = PhaseBanner.new()
	add_child(phase_banner)
	turn_manager.phase_changed.connect(_on_phase_changed)
	
	action_menu = ActionMenu.new()
	add_child(action_menu)
	action_menu.option_selected.connect(_on_action_selected)
	action_menu.cancelled.connect(_on_action_cancelled)
	
	player_action_menu = PlayerActionMenu.new()
	add_child(player_action_menu)
	player_action_menu.option_selected.connect(_on_player_action_selected)
	
	inventory_menu = InventoryMenu.new()
	add_child(inventory_menu)
	inventory_menu.slot_selected.connect(_on_inventory_slot_selected)
	inventory_menu.cancelled.connect(_on_inventory_cancelled)
	
	item_slot_action_menu = ItemSlotActionMenuScript.new()
	add_child(item_slot_action_menu)
	item_slot_action_menu.option_selected.connect(_on_item_slot_action_selected)
	item_slot_action_menu.cancelled.connect(_on_item_slot_action_cancelled)
	
	confirmation_dialog = CustomConfirmationDialogScript.new()
	add_child(confirmation_dialog)
	confirmation_dialog.confirmed.connect(_on_discard_confirmed)
	confirmation_dialog.cancelled.connect(_on_discard_cancelled)
	
	weapon_selection_menu = WeaponSelectionMenuScript.new()
	add_child(weapon_selection_menu)
	weapon_selection_menu.weapon_selected.connect(_on_weapon_selected_for_attack)
	weapon_selection_menu.cancelled.connect(_on_weapon_selection_cancelled)
	
	combat_preview = CombatPreview.new()
	add_child(combat_preview)
	combat_preview.attack_confirmed.connect(_on_attack_confirmed)
	combat_preview.attack_cancelled.connect(_on_attack_cancelled)

	# Setup hover banner
	hover_banner = preload("res://scenes/UI/unit_hover_banner.tscn").instantiate()
	add_child(hover_banner)
	EventBus.unit_hovered.connect(_on_unit_hovered)
	EventBus.unit_hover_ended.connect(_on_unit_hover_ended)
	
	# Setup inspect screen
	var inspect_script := load("res://scripts/unit_inspect_screen.gd")
	inspect_screen = inspect_script.new()
	add_child(inspect_screen)
	
	# Setup target selection banner
	var banner_script := load("res://scripts/target_selection_banner.gd")
	target_selection_banner = banner_script.new()
	add_child(target_selection_banner)
	
	# Setup grid cursor
	grid_cursor = GridCursor.new()
	grid_cursor.setup(cursor_coord)
	add_child(grid_cursor)
	
	# Setup dev console
	DevConsole.setup(self)

func _initialize_tiles() -> void:
	for x in range(Constants.GRID_WIDTH):
		for y in range(Constants.GRID_HEIGHT):
			var coord := Vector2i(x, y)
			tiles[coord] = Tile.new(coord)

func _draw_grid() -> void:
	for coord in tiles.keys():
		var tile_visual := TileVisual.new()
		tile_visual.setup(coord)
		add_child(tile_visual)
		tile_visuals[coord] = tile_visual

func get_tile(coord: Vector2i) -> Tile:
	return tiles.get(coord)

func is_within_bounds(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < Constants.GRID_WIDTH and coord.y >= 0 and coord.y < Constants.GRID_HEIGHT

func is_tile_empty(coord: Vector2i) -> bool:
	var tile := get_tile(coord)
	if tile:
		return tile.is_empty()
	return false

func world_to_grid(world_position: Vector2) -> Vector2i:
	return Vector2i(
		int(world_position.x / Constants.TILE_SIZE),
		int(world_position.y / Constants.TILE_SIZE)
	)

func grid_to_world(coord: Vector2i) -> Vector2:
	return Vector2(
		coord.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0,
		coord.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0
	)

func get_manhattan_distance(from: Vector2i, to: Vector2i) -> int:
	return abs(from.x - to.x) + abs(from.y - to.y)

func get_adjacent_tiles(coord: Vector2i) -> Array[Vector2i]:
	var adjacent: Array[Vector2i] = []
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for dir in directions:
		var neighbor: Vector2i = coord + dir
		if is_within_bounds(neighbor):
			adjacent.append(neighbor)
	return adjacent

func spawn_unit(unit_data: UnitData) -> Unit:
	var unit: Unit = UnitScene.instantiate()
	unit.setup(unit_data)
	add_child(unit)
	units.append(unit)
	
	var tile := get_tile(unit_data.coordinate)
	tile.set_occupant(unit, unit_data.unit_type)
	
	# Give Cleric starting spell
	if unit_data.class_id == Enums.ClassID.CLERIC and not unit_data.has_spell("Soothing Light"):
		unit_data.learn_spell("Soothing Light")
	
	return unit

func _spawn_test_unit() -> void:
	# Captain
	var captain_stats := StatsDatabase.get_stats_for_level(Enums.ClassID.CAPTAIN, 1)
	var player_data := UnitData.new()
	player_data.unit_name = "Test Captain"
	player_data.unit_type = Enums.UnitType.PLAYER
	player_data.class_id = Enums.ClassID.CAPTAIN
	player_data.tier = Enums.Tier.BASE
	player_data.level = 1
	player_data.affinity = Enums.Element.FIRE
	player_data.coordinate = Vector2i(4, 4)
	player_data.hp_max = captain_stats["hp"]
	player_data.hp_current = captain_stats["hp"]
	player_data.atk = captain_stats["atk"]
	player_data.def = captain_stats["def"]
	player_data.spd = captain_stats["spd"]
	player_data.int_stat = captain_stats["int"]
	player_data.res = captain_stats["res"]
	player_data.luk = captain_stats["luk"]
	player_data.equipped_weapon = WeaponDatabase.get_weapon("Training Sword")
	player_data.xp_to_next_level = ExperienceManager.get_xp_required_for_level(player_data.tier, player_data.level + 1)
	spawn_unit(player_data)
	
	# Archer
	var archer_stats := StatsDatabase.get_stats_for_level(Enums.ClassID.ARCHER, 1)
	var player_data_2 := UnitData.new()
	player_data_2.unit_name = "Test Archer"
	player_data_2.unit_type = Enums.UnitType.PLAYER
	player_data_2.class_id = Enums.ClassID.ARCHER
	player_data_2.tier = Enums.Tier.BASE
	player_data_2.level = 1
	player_data_2.affinity = Enums.Element.WIND
	player_data_2.coordinate = Vector2i(3, 5)
	player_data_2.hp_max = archer_stats["hp"]
	player_data_2.hp_current = archer_stats["hp"]
	player_data_2.atk = archer_stats["atk"]
	player_data_2.def = archer_stats["def"]
	player_data_2.spd = archer_stats["spd"]
	player_data_2.int_stat = archer_stats["int"]
	player_data_2.res = archer_stats["res"]
	player_data_2.luk = archer_stats["luk"]
	player_data_2.equipped_weapon = WeaponDatabase.get_weapon("Training Shortbow")
	player_data_2.xp_to_next_level = ExperienceManager.get_xp_required_for_level(player_data_2.tier, player_data_2.level + 1)
	spawn_unit(player_data_2)
	
	# Mage
	var mage_stats := StatsDatabase.get_stats_for_level(Enums.ClassID.MAGE, 1)
	var player_data_3 := UnitData.new()
	player_data_3.unit_name = "Test Mage"
	player_data_3.unit_type = Enums.UnitType.PLAYER
	player_data_3.class_id = Enums.ClassID.MAGE
	player_data_3.tier = Enums.Tier.BASE
	player_data_3.level = 1
	player_data_3.affinity = Enums.Element.LIGHTNING
	player_data_3.coordinate = Vector2i(5, 5)
	player_data_3.hp_max = mage_stats["hp"]
	player_data_3.hp_current = mage_stats["hp"]
	player_data_3.atk = mage_stats["atk"]
	player_data_3.def = mage_stats["def"]
	player_data_3.spd = mage_stats["spd"]
	player_data_3.int_stat = mage_stats["int"]
	player_data_3.res = mage_stats["res"]
	player_data_3.luk = mage_stats["luk"]
	player_data_3.equipped_weapon = WeaponDatabase.get_weapon("Training Wand")
	player_data_3.xp_to_next_level = ExperienceManager.get_xp_required_for_level(player_data_3.tier, player_data_3.level + 1)
	spawn_unit(player_data_3)
	
	# Enemy Warrior
	var warrior_stats := StatsDatabase.get_stats_for_level(Enums.ClassID.WARRIOR, 1)
	var enemy_data := UnitData.new()
	enemy_data.unit_name = "Enemy Warrior"
	enemy_data.unit_type = Enums.UnitType.ENEMY
	enemy_data.class_id = Enums.ClassID.WARRIOR
	enemy_data.tier = Enums.Tier.BASE
	enemy_data.level = 1
	enemy_data.affinity = Enums.Element.WATER
	enemy_data.coordinate = Vector2i(6, 3)
	enemy_data.hp_max = warrior_stats["hp"]
	enemy_data.hp_current = warrior_stats["hp"]
	enemy_data.atk = warrior_stats["atk"]
	enemy_data.def = warrior_stats["def"]
	enemy_data.spd = warrior_stats["spd"]
	enemy_data.int_stat = warrior_stats["int"]
	enemy_data.res = warrior_stats["res"]
	enemy_data.luk = warrior_stats["luk"]
	enemy_data.equipped_weapon = WeaponDatabase.get_weapon("Training Axe")
	enemy_data.xp_to_next_level = ExperienceManager.get_xp_required_for_level(enemy_data.tier, enemy_data.level + 1)
	spawn_unit(enemy_data)
	
	# Test Hero with War Cry
	var hero_stats := StatsDatabase.get_stats_for_level(Enums.ClassID.HERO, 10)
	var hero_data := UnitData.new()
	hero_data.unit_name = "Test Hero"
	hero_data.unit_type = Enums.UnitType.PLAYER
	hero_data.class_id = Enums.ClassID.HERO
	hero_data.tier = Enums.Tier.MASTERY
	hero_data.level = 10
	hero_data.affinity = Enums.Element.FIRE
	hero_data.coordinate = Vector2i(2, 4)
	hero_data.hp_max = hero_stats["hp"]
	hero_data.hp_current = hero_stats["hp"]
	hero_data.atk = hero_stats["atk"]
	hero_data.def = hero_stats["def"]
	hero_data.spd = hero_stats["spd"]
	hero_data.int_stat = hero_stats["int"]
	hero_data.res = hero_stats["res"]
	hero_data.luk = hero_stats["luk"]
	hero_data.equipped_weapon = WeaponDatabase.get_weapon("Training Sword")
	hero_data.innate_esotera = ["War Cry"]
	hero_data.xp_to_next_level = ExperienceManager.get_xp_required_for_level(hero_data.tier, hero_data.level + 1)
	spawn_unit(hero_data)

func get_tiles_in_movement_range(origin: Vector2i, movement_range: int, unit_type: Enums.UnitType) -> Array[Vector2i]:
	var reachable: Array[Vector2i] = []
	var visited: Dictionary = {}
	var queue: Array = [[origin, 0]]
	
	visited[origin] = true
	
	while queue.size() > 0:
		var current: Array = queue.pop_front()
		var coord: Vector2i = current[0]
		var distance: int = current[1]
		
		if distance > 0:
			reachable.append(coord)
		
		if distance < movement_range:
			for neighbor in get_adjacent_tiles(coord):
				if visited.has(neighbor):
					continue
				
				var tile := get_tile(neighbor)
				if tile.state == Enums.TileState.OBSTACLE:
					continue
				if tile.state == Enums.TileState.ENEMY_UNIT and unit_type == Enums.UnitType.PLAYER:
					continue
				if tile.state == Enums.TileState.PLAYER_UNIT and unit_type == Enums.UnitType.ENEMY:
					continue
				
				visited[neighbor] = true
				queue.append([neighbor, distance + 1])
	
	return reachable

func get_tiles_in_attack_range(origin: Vector2i, attack_range: Enums.AttackRange, unit_type: Enums.UnitType) -> Array[Vector2i]:
	var attackable: Array[Vector2i] = []
	
	match attack_range:
		Enums.AttackRange.RANGE_0:
			return attackable
		Enums.AttackRange.RANGE_1:
			for tile_coord in tiles.keys():
				if get_manhattan_distance(origin, tile_coord) == 1:
					attackable.append(tile_coord)
		Enums.AttackRange.RANGE_1_2:
			for tile_coord in tiles.keys():
				var dist := get_manhattan_distance(origin, tile_coord)
				if dist == 1 or dist == 2:
					attackable.append(tile_coord)
		Enums.AttackRange.RANGE_2:
			for tile_coord in tiles.keys():
				if get_manhattan_distance(origin, tile_coord) == 2:
					attackable.append(tile_coord)
	
	return attackable

func find_path(origin: Vector2i, destination: Vector2i, movement_range: int, unit_type: Enums.UnitType) -> Array[Vector2i]:
	if not is_within_bounds(destination):
		return []
	
	var frontier: Array = [[origin, 0]]
	var came_from: Dictionary = {}
	var cost_so_far: Dictionary = {}
	
	came_from[origin] = null
	cost_so_far[origin] = 0
	
	while frontier.size() > 0:
		frontier.sort_custom(func(a, b): return a[1] < b[1])
		var current: Vector2i = frontier.pop_front()[0]
		
		if current == destination:
			break
		
		for neighbor in get_adjacent_tiles(current):
			var tile := get_tile(neighbor)
			
			if tile.state == Enums.TileState.OBSTACLE:
				continue
			if tile.state == Enums.TileState.ENEMY_UNIT and unit_type == Enums.UnitType.PLAYER:
				continue
			if tile.state == Enums.TileState.PLAYER_UNIT and unit_type == Enums.UnitType.ENEMY:
				continue
			
			var new_cost: int = cost_so_far[current] + 1
			
			if new_cost > movement_range:
				continue
			
			if not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				var priority: int = new_cost + get_manhattan_distance(neighbor, destination)
				frontier.append([neighbor, priority])
				came_from[neighbor] = current
	
	if not came_from.has(destination):
		return []
	
	var path: Array[Vector2i] = []
	var current: Vector2i = destination
	while current != origin:
		path.append(current)
		current = came_from[current]
	path.reverse()
	
	return path

func highlight_tiles(coords: Array[Vector2i]) -> void:
	for coord in coords:
		if tile_visuals.has(coord):
			tile_visuals[coord].set_highlight(true)

func clear_highlights() -> void:
	for tile_visual in tile_visuals.values():
		tile_visual.set_highlight(false)

func highlight_attack_tiles(coords: Array[Vector2i]) -> void:
	for coord in coords:
		if tile_visuals.has(coord):
			if not tile_visuals[coord].is_move_highlighted:
				tile_visuals[coord].set_attack_highlight(true)

func clear_attack_highlights() -> void:
	for tile_visual in tile_visuals.values():
		tile_visual.set_attack_highlight(false)

func _input(event: InputEvent) -> void:
	# When DevConsole is open, only allow grid input during tile selection states
	if DevConsole.console_visible:
		# Only block grid input if DevConsole is in IDLE or certain active states
		# Let DevConsole UI handle its own mouse clicks
		if event is InputEventMouseButton:
			# Check if click is on DevConsole panel area
			var console_panel_rect := Rect2(DevConsole.panel.global_position, DevConsole.panel.size)
			if console_panel_rect.has_point(event.position):
				# Click is on console, let it handle
				return
		
		# Block grid actions when console is in IDLE state
		if DevConsole.current_state == DevConsole.State.IDLE:
			return
		# Console is waiting for grid input - allow cursor movement and confirm/cancel
	
	if phase_banner.is_animating:
		return
	
	if combat_preview.is_visible:
		return
	
	if player_action_menu.is_visible:
		return
	
	if inventory_menu.is_visible:
		return
	
	if item_slot_action_menu.is_visible:
		return
	
	if confirmation_dialog.is_visible:
		return
	
	if weapon_selection_menu.is_visible:
		return
	
	if is_selecting_target or is_casting_spell:
		if InputManager.is_confirm_pressed(event):
			if event is InputEventMouseButton:
				var local_click: Vector2 = event.position - global_position
				var clicked_coord := world_to_grid(local_click)
				_handle_target_click(clicked_coord)
			else:
				# Keyboard confirm - use cursor position
				_handle_target_click(cursor_coord)
			get_viewport().set_input_as_handled()
			return
		
		if InputManager.is_cancel_pressed(event):
			if is_casting_spell:
				_cancel_spell_target_selection()
				_show_action_menu_at_current_position()
			else:
				_cancel_target_selection()
				_on_action_cancelled()
			get_viewport().set_input_as_handled()
			return
	
	if is_awaiting_action:
		if InputManager.is_cancel_pressed(event):
			_on_action_cancelled()
			get_viewport().set_input_as_handled()
			return
	
	# Keyboard cursor movement
	var move_dir := InputManager.get_movement_direction(event)
	if move_dir != Vector2i.ZERO:
		if is_selecting_target:
			_cycle_target_selection(move_dir)
			get_viewport().set_input_as_handled()
		else:
			var new_coord := cursor_coord + move_dir
			if is_within_bounds(new_coord):
				cursor_coord = new_coord
				grid_cursor.move_to(cursor_coord)
				_update_path_preview(cursor_coord)
				_handle_enemy_hover(cursor_coord)
				_handle_cursor_unit_hover(cursor_coord)
				get_viewport().set_input_as_handled()
	
	# Keyboard confirm/cancel actions
	if InputManager.is_confirm_pressed(event):
		# Check if DevConsole is handling the input
		if DevConsole.console_visible and DevConsole.handle_tile_click(cursor_coord):
			get_viewport().set_input_as_handled()
			return
		
		if is_within_bounds(cursor_coord):
			if is_selecting_target or is_casting_spell:
				_handle_target_click(cursor_coord)
			else:
				_handle_tile_click(cursor_coord)
		get_viewport().set_input_as_handled()
		return
	
# Handle keyboard cancel (X key) - but NOT mouse right-click yet
	if InputManager.is_cancel_pressed(event) and event is InputEventKey:
		# Cancel DevConsole actions first
		if DevConsole.current_state != DevConsole.State.IDLE:
			DevConsole.handle_cancel()
			get_viewport().set_input_as_handled()
			return
		
		if selected_unit != null:
			_deselect_unit()
			get_viewport().set_input_as_handled()
			return
	
	if event is InputEventMouseMotion:
		var local_pos: Vector2 = event.position - global_position
		var hovered_coord := world_to_grid(local_pos)
		
		if is_within_bounds(hovered_coord):
			_update_path_preview(hovered_coord)
			_handle_enemy_hover(hovered_coord)
			_update_cursor_position(hovered_coord)
		else:
			_clear_enemy_hover()
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_click: Vector2 = event.position - global_position
			var clicked_coord := world_to_grid(local_click)
			
			if not is_within_bounds(clicked_coord):
				return
			
			_handle_tile_click(clicked_coord)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var local_click: Vector2 = event.position - global_position
			var clicked_coord := world_to_grid(local_click)
			
			# Priority 1: Inspect unit if clicked on one
			if is_within_bounds(clicked_coord):
				var tile := get_tile(clicked_coord)
				if tile and tile.occupant:
					_show_unit_inspect(tile.occupant.data)
					get_viewport().set_input_as_handled()
					return
			
			# Priority 2: Deselect if unit selected
			if selected_unit != null:
				_deselect_unit()
			# Priority 3: Show player menu ONLY if DevConsole is closed
			elif not DevConsole.console_visible:
				player_action_menu.show_player_menu(event.position)

func _handle_target_click(coord: Vector2i) -> void:
	var tile := get_tile(coord)
	if tile == null:
		return
	
	if tile.occupant != null and valid_targets.has(tile.occupant):
		var target: Unit = tile.occupant
		pending_target = target
		
		# If casting spell, execute spell immediately
		if is_casting_spell:
			_execute_spell_cast(target)
			return
		
		# Show weapon selection menu if unit has multiple weapons
		var has_multiple_weapons := (selected_unit.data.equipped_weapon != null and selected_unit.data.inventory_weapon != null)
		
		if has_multiple_weapons:
			var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
			weapon_selection_menu.show_weapon_selection(screen_pos, selected_unit)
		else:
			# Only one weapon, go directly to combat preview
			_show_combat_preview_for_target()

func _handle_tile_click(coord: Vector2i) -> void:
	var tile := get_tile(coord)
	
	if not turn_manager.is_player_phase():
		return
	
	if selected_unit == null:
		if tile.occupant != null and tile.state == Enums.TileState.PLAYER_UNIT:
			var unit: Unit = tile.occupant
			if not unit.is_exhausted():
				_select_unit(unit)
		return
	
	if just_selected:
		just_selected = false
		# Allow immediate action if clicking on same tile or highlighted tile
		if coord == selected_unit.data.coordinate or (tile.is_empty() and tile_visuals[coord].is_move_highlighted):
			pass  # Continue to action below
		else:
			return
	
	if tile.is_empty() and tile_visuals[coord].is_move_highlighted:
		_show_action_menu(coord)
	elif coord == selected_unit.data.coordinate:
		_show_action_menu(coord)
	else:
		_deselect_unit()

func _select_unit(unit: Unit) -> void:
	selected_unit = unit
	just_selected = true
	var movement_range := unit.data.get_movement_range()
	var reachable := get_tiles_in_movement_range(unit.data.coordinate, movement_range, unit.data.unit_type)
	highlight_tiles(reachable)
	
	var all_attack_tiles: Array[Vector2i] = []
	var positions_to_check: Array[Vector2i] = reachable.duplicate()
	positions_to_check.append(unit.data.coordinate)
	
	for pos in positions_to_check:
		var attack_tiles := get_tiles_in_attack_range(pos, unit.data.get_attack_range(), unit.data.unit_type)
		for tile in attack_tiles:
			if not all_attack_tiles.has(tile) and not reachable.has(tile) and tile != unit.data.coordinate:
				all_attack_tiles.append(tile)
	
	highlight_attack_tiles(all_attack_tiles)

func _deselect_unit() -> void:
	selected_unit = null
	clear_highlights()
	clear_attack_highlights()
	path_visual.clear_path()

func _show_action_menu(coord: Vector2i) -> void:
	pending_move_coord = coord
	is_awaiting_action = true
	path_visual.clear_path()
	
	selected_unit.store_original_position()
	
	if coord != selected_unit.data.coordinate:
		var old_tile := get_tile(selected_unit.data.coordinate)
		old_tile.clear_occupant()
		
		var new_tile := get_tile(coord)
		new_tile.set_occupant(selected_unit, selected_unit.data.unit_type)
		
		selected_unit.move_to(coord)
	
	clear_highlights()
	clear_attack_highlights()
	
	var can_attack := _check_can_attack_from(coord)
	var screen_pos := _get_menu_screen_position(coord)
	action_menu.show_menu_for_unit(screen_pos, can_attack, selected_unit)

func _check_can_attack_from(coord: Vector2i) -> bool:
	var attack_tiles := get_tiles_in_attack_range(coord, selected_unit.data.get_attack_range(), selected_unit.data.unit_type)
	for tile_coord in attack_tiles:
		var tile := get_tile(tile_coord)
		if tile.state == Enums.TileState.ENEMY_UNIT:
			return true
	return false

func _get_menu_screen_position(coord: Vector2i) -> Vector2:
	var world_pos := grid_to_world(coord)
	return world_pos + global_position + Vector2(Constants.TILE_SIZE / 2.0, 0)

func _on_action_selected(option_id: String) -> void:
	is_awaiting_action = false
	
	# Check if this is an esotera action
	if option_id.begins_with("esotera_"):
		var esotera_name: String = option_id.substr(8)  # Remove "esotera_" prefix
		_use_esotera(esotera_name)
		return
	
	match option_id:
		"attack":
			_start_target_selection()
			return
		"spell":
			_show_spell_selection()
			return
		"inventory":
			_show_inventory_menu()
			return
		"wait":
			_execute_move()
	
	_deselect_unit()
	turn_manager.check_player_phase_end()

func _on_action_cancelled() -> void:
	is_awaiting_action = false
	action_menu.hide_menu()
	
	if selected_unit.data.coordinate != selected_unit.original_coordinate:
		var current_tile := get_tile(selected_unit.data.coordinate)
		current_tile.clear_occupant()
		
		var original_tile := get_tile(selected_unit.original_coordinate)
		original_tile.set_occupant(selected_unit, selected_unit.data.unit_type)
		
		selected_unit.revert_to_original_position()
	
	_deselect_unit()

func _execute_move() -> void:
	selected_unit.set_exhausted()
	if pending_move_coord == selected_unit.data.coordinate:
		selected_unit.set_exhausted()
		return
	
	var old_tile := get_tile(selected_unit.data.coordinate)
	old_tile.clear_occupant()
	
	var new_tile := get_tile(pending_move_coord)
	new_tile.set_occupant(selected_unit, selected_unit.data.unit_type)
	
	selected_unit.move_to(pending_move_coord)
	selected_unit.set_exhausted()

func _update_path_preview(coord: Vector2i) -> void:
	if selected_unit == null:
		path_visual.clear_path()
		return
	
	if not tile_visuals.has(coord) or not tile_visuals[coord].is_move_highlighted:
		path_visual.clear_path()
		return
	
	var path := find_path(
		selected_unit.data.coordinate,
		coord,
		selected_unit.data.get_movement_range(),
		selected_unit.data.unit_type
	)
	path_visual.set_path(path)

func _on_phase_changed(phase: Enums.Phase) -> void:
	phase_banner.show_phase(phase)
	
	if phase == Enums.Phase.ENEMY_PHASE:
		await phase_banner.animation_finished
		turn_manager.begin_enemy_actions()

func highlight_target_tiles(coords: Array[Vector2i]) -> void:
	for coord in coords:
		if tile_visuals.has(coord):
			tile_visuals[coord].set_target_highlight(true)

func clear_target_highlights() -> void:
	for tile_visual in tile_visuals.values():
		tile_visual.set_target_highlight(false)

func _start_target_selection() -> void:
	is_selecting_target = true
	valid_targets.clear()
	target_selection_banner.show_banner()
	
	var attack_tiles := get_tiles_in_attack_range(selected_unit.data.coordinate, selected_unit.data.get_attack_range(), selected_unit.data.unit_type)
	var target_coords: Array[Vector2i] = []
	
	for coord in attack_tiles:
		var tile := get_tile(coord)
		if tile.state == Enums.TileState.ENEMY_UNIT:
			target_coords.append(coord)
			valid_targets.append(tile.occupant)
	
	highlight_target_tiles(target_coords)
	
	# Snap cursor to first valid target
	if valid_targets.size() > 0:
		cursor_coord = valid_targets[0].data.coordinate
		grid_cursor.move_to(cursor_coord)
		_handle_cursor_unit_hover(cursor_coord)

func _cancel_target_selection() -> void:
	is_selecting_target = false
	valid_targets.clear()
	clear_target_highlights()
	target_selection_banner.hide_banner()

func _on_combat_finished() -> void:
	if selected_unit != null:
		selected_unit.set_exhausted()
		_deselect_unit()
		turn_manager.check_player_phase_end()
	elif turn_manager.is_processing_enemy:
		# Determine if enemy died by checking if index is still valid
		var enemy_died := turn_manager.current_enemy_index >= turn_manager.enemy_units.size()
		
		# If enemy still alive, set exhausted
		if not enemy_died:
			var enemy := turn_manager.enemy_units[turn_manager.current_enemy_index]
			enemy.set_exhausted()
		
		turn_manager._on_enemy_action_done(enemy_died)

func _on_unit_died(unit: Unit) -> void:
	# Clear enemy highlights if this was the hovered enemy
	if unit == hovered_enemy:
		_clear_enemy_hover()
	
	var tile := get_tile(unit.data.coordinate)
	tile.clear_occupant()
	units.erase(unit)
	
	if unit.data.unit_type == Enums.UnitType.PLAYER:
		turn_manager.player_units.erase(unit)
	else:
		turn_manager.enemy_units.erase(unit)
	
	unit.queue_free()

func _on_damage_dealt(attacker: Unit, defender: Unit, damage: int, is_crit: bool) -> void:
	if damage == 0:
		print(attacker.data.unit_name, " missed!")
	elif is_crit:
		print(attacker.data.unit_name, " CRIT ", defender.data.unit_name, " for ", damage, " damage! (HP: ", defender.data.hp_current, "/", defender.data.hp_max, ")")
	else:
		print(attacker.data.unit_name, " hit ", defender.data.unit_name, " for ", damage, " damage! (HP: ", defender.data.hp_current, "/", defender.data.hp_max, ")")

func _on_player_action_selected(option_id: String) -> void:
	match option_id:
		"end_phase":
			turn_manager.end_player_phase()

func _on_attack_confirmed() -> void:
	_cancel_target_selection()
	combat_manager.execute_combat(selected_unit, pending_target)
	pending_target = null

func _on_attack_cancelled() -> void:
	pending_target = null
	_cancel_target_selection()
	
	# Revert unit to original position
	var current_tile := get_tile(selected_unit.data.coordinate)
	current_tile.clear_occupant()
	
	var original_tile := get_tile(selected_unit.original_coordinate)
	original_tile.set_occupant(selected_unit, selected_unit.data.unit_type)
	
	selected_unit.revert_to_original_position()
	_deselect_unit()

func _on_weapon_selected_for_attack(slot_index: int) -> void:
	# Equip the selected weapon for this attack
	var weapon := selected_unit.data.get_weapon_at_slot(slot_index)
	if weapon and selected_unit.data.can_equip_weapon_type(weapon):
		# Temporarily swap weapons if needed
		if slot_index == 1 and selected_unit.data.inventory_weapon:
			# Swap slot 1 with equipped
			var temp := selected_unit.data.equipped_weapon
			selected_unit.data.equipped_weapon = selected_unit.data.inventory_weapon
			selected_unit.data.inventory_weapon = temp
		# If slot_index == 0, already equipped
		# If slot_index == 2 (shield), can't attack with it so this shouldn't happen
	
	# Now show combat preview
	_show_combat_preview_for_target()

func _on_weapon_selection_cancelled() -> void:
	# Cancel the attack entirely
	pending_target = null
	_cancel_target_selection()
	_on_action_cancelled()

func _show_combat_preview_for_target() -> void:
	if pending_target:
		var dist := get_manhattan_distance(selected_unit.data.coordinate, pending_target.data.coordinate)
		combat_preview.show_preview(selected_unit, pending_target, dist)

func _highlight_enemy_range(enemy: Unit) -> void:
	var movement_range := enemy.data.get_movement_range()
	var reachable := get_tiles_in_movement_range(enemy.data.coordinate, movement_range, enemy.data.unit_type)
	
	for coord in reachable:
		if tile_visuals.has(coord):
			tile_visuals[coord].set_enemy_move_highlight(true)
	
	var all_attack_tiles: Array[Vector2i] = []
	var positions_to_check: Array[Vector2i] = reachable.duplicate()
	positions_to_check.append(enemy.data.coordinate)
	
	for pos in positions_to_check:
		var attack_tiles := get_tiles_in_attack_range(pos, enemy.data.get_attack_range(), enemy.data.unit_type)
		for tile in attack_tiles:
			if not all_attack_tiles.has(tile) and not reachable.has(tile) and tile != enemy.data.coordinate:
				all_attack_tiles.append(tile)
	
	for coord in all_attack_tiles:
		if tile_visuals.has(coord):
			tile_visuals[coord].set_enemy_attack_highlight(true)

func _clear_enemy_highlights() -> void:
	for tile_visual in tile_visuals.values():
		tile_visual.set_enemy_move_highlight(false)
		tile_visual.set_enemy_attack_highlight(false)
		
func _handle_enemy_hover(coord: Vector2i) -> void:
	if action_menu.panel.visible or player_action_menu.is_visible or inspect_screen.visible:
		hover_banner.hide_banner()
		return
	var tile := get_tile(coord)
	
	if tile.state == Enums.TileState.ENEMY_UNIT and tile.occupant != null:
		var enemy: Unit = tile.occupant
		if enemy != hovered_enemy:
			_clear_enemy_highlights()
			hovered_enemy = enemy
			_highlight_enemy_range(enemy)
	elif hovered_enemy != null:
		_clear_enemy_hover()

func _clear_enemy_hover() -> void:
	if hovered_enemy != null:
		_clear_enemy_highlights()
		hovered_enemy = null

func _on_unit_hovered(unit_data: UnitData, mouse_pos: Vector2) -> void:
	if action_menu.panel.visible or player_action_menu.is_visible or inspect_screen.visible:
		return
	hover_banner.show_for_unit(unit_data, mouse_pos)

func _on_unit_hover_ended() -> void:
	hover_banner.hide_banner()

func _show_unit_inspect(unit_data: UnitData) -> void:
	inspect_screen.show_unit_inspect(unit_data)

func _update_cursor_position(coord: Vector2i) -> void:
	if cursor_coord != coord:
		cursor_coord = coord
		grid_cursor.move_to(cursor_coord)

func _handle_cursor_unit_hover(coord: Vector2i) -> void:
	if action_menu.panel.visible or player_action_menu.is_visible or inspect_screen.visible:
		hover_banner.hide_banner()
		return
	var tile := get_tile(coord)
	
	if tile and tile.occupant:
		var world_pos := grid_to_world(coord) + global_position
		EventBus.unit_hovered.emit(tile.occupant.data, world_pos)
	else:
		EventBus.unit_hover_ended.emit()

func _cycle_target_selection(direction: Vector2i) -> void:
	if valid_targets.size() == 0:
		return
	
	var current_target_index := -1
	for i in valid_targets.size():
		if valid_targets[i].data.coordinate == cursor_coord:
			current_target_index = i
			break
	
	if current_target_index == -1:
		current_target_index = 0
	else:
		# Cycle through targets based on direction
		if direction.x > 0 or direction.y > 0:  # Right or Down
			current_target_index = (current_target_index + 1) % valid_targets.size()
		else:  # Left or Up
			current_target_index = (current_target_index - 1 + valid_targets.size()) % valid_targets.size()
	
	cursor_coord = valid_targets[current_target_index].data.coordinate
	grid_cursor.move_to(cursor_coord)
	_handle_cursor_unit_hover(cursor_coord)

func _equip_weapon(slot_index: int) -> void:
	var weapon_to_equip: WeaponData = null
	
	if slot_index == 0:
		weapon_to_equip = selected_unit.data.equipped_weapon
	else:
		weapon_to_equip = selected_unit.data.inventory_weapon
		selected_unit.data.inventory_weapon = null
	
	# Move currently equipped to slot 2 if exists
	if selected_unit.data.equipped_weapon and slot_index == 1:
		selected_unit.data.inventory_weapon = selected_unit.data.equipped_weapon
	
	selected_unit.data.equipped_weapon = weapon_to_equip

func _show_inventory_menu() -> void:
	action_menu.hide_menu()
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	inventory_menu.show_inventory(screen_pos, selected_unit)

func _on_inventory_slot_selected(slot_type: String, slot_index: int) -> void:
	pending_inventory_slot_type = slot_type
	pending_inventory_slot_index = slot_index
	
	inventory_menu.hide_menu()
	
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	
	if slot_type == "equipment":
		var weapon := selected_unit.data.get_weapon_at_slot(slot_index)
		if weapon == null:
			# Empty slot - re-show inventory
			inventory_menu.show_inventory(screen_pos, selected_unit)
			return
		
		var is_equipped := selected_unit.data.is_slot_equipped_weapon(slot_index)
		var is_shield := weapon.weapon_type == Enums.WeaponType.SHIELD
		item_slot_action_menu.show_equipment_menu(screen_pos, is_equipped, is_shield)
	
	elif slot_type == "item":
		var item_name := selected_unit.data.get_item_at_slot(slot_index)
		if item_name.is_empty():
			# Empty slot - re-show inventory
			inventory_menu.show_inventory(screen_pos, selected_unit)
			return
		
		item_slot_action_menu.show_item_menu(screen_pos, selected_unit.data, item_name)

func _on_inventory_cancelled() -> void:
	inventory_menu.hide_menu()
	# Re-show action menu
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	var can_attack := _check_can_attack_from(selected_unit.data.coordinate)
	action_menu.show_menu_for_unit(screen_pos, can_attack, selected_unit)

func _on_item_slot_action_selected(option_id: String) -> void:
	item_slot_action_menu.hide_menu()
	
	match option_id:
		"equip":
			_equip_from_slot()
			_refresh_inventory_menu()
		"unequip":
			_unequip_from_slot()
			_refresh_inventory_menu()
		"use":
			_use_item_from_slot()
			_refresh_inventory_menu()
		"discard":
			_show_discard_confirmation()

func _on_item_slot_action_cancelled() -> void:
	item_slot_action_menu.hide_menu()
	_refresh_inventory_menu()

func _equip_from_slot() -> void:
	var weapon := selected_unit.data.get_weapon_at_slot(pending_inventory_slot_index)
	if weapon:
		# Check if unit can equip this weapon
		if not selected_unit.data.can_equip_weapon_type(weapon):
			print("Cannot equip %s - unit lacks proficiency" % weapon.weapon_name)
			return
		selected_unit.data.equip_weapon(weapon, pending_inventory_slot_index)

func _unequip_from_slot() -> void:
	selected_unit.data.unequip_weapon(pending_inventory_slot_index)

func _use_item_from_slot() -> void:
	var result := selected_unit.data.use_item(pending_inventory_slot_index)
	print(result)

func _show_discard_confirmation() -> void:
	var item_name := ""
	
	if pending_inventory_slot_type == "equipment":
		var weapon := selected_unit.data.get_weapon_at_slot(pending_inventory_slot_index)
		if weapon:
			item_name = weapon.weapon_name
	else:
		item_name = selected_unit.data.get_item_at_slot(pending_inventory_slot_index)
	
	if item_name.is_empty():
		_refresh_inventory_menu()
		return
	
	confirmation_dialog.show_dialog("Discard %s?" % item_name)

func _on_discard_confirmed() -> void:
	if pending_inventory_slot_type == "equipment":
		selected_unit.data.discard_weapon(pending_inventory_slot_index)
	else:
		selected_unit.data.discard_item(pending_inventory_slot_index)
	
	_refresh_inventory_menu()

func _on_discard_cancelled() -> void:
	_refresh_inventory_menu()

func _refresh_inventory_menu() -> void:
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	inventory_menu.show_inventory(screen_pos, selected_unit)


func _use_esotera(esotera_name: String) -> void:
	if not selected_unit.data.can_use_esotera(esotera_name):
		print("Cannot use ", esotera_name, " - already used this floor")
		return
	
	# Mark as used
	selected_unit.data.mark_esotera_used(esotera_name)
	
	# Apply effect
	EsoteraDatabase.apply_esotera_effect(esotera_name, selected_unit)
	
	print(selected_unit.data.unit_name, " used ", esotera_name)
	
	# Complete the unit's turn
	_execute_move()
	_deselect_unit()
	turn_manager.check_player_phase_end()

func _show_spell_selection() -> void:
	is_selecting_spell = true
	action_menu.hide_menu()
	
	# Create simple spell selection menu
	if not weapon_selection_menu:
		weapon_selection_menu = WeaponSelectionMenuScript.new()
		add_child(weapon_selection_menu)
		weapon_selection_menu.weapon_selected.connect(_on_spell_selected)
		weapon_selection_menu.cancelled.connect(_on_spell_selection_cancelled)
	
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	
	# Build spell list with availability
	var spell_options := []
	for spell_name in selected_unit.data.learned_spells:
		var spell := SpellDatabase.get_spell(spell_name)
		if spell:
			var is_ready: bool = selected_unit.data.is_spell_ready(spell_name)
			var display_name: String = spell_name
			if not is_ready:
				var cooldown: int = selected_unit.data.spell_cooldowns.get(spell_name, 0)
				display_name += " (" + str(cooldown) + ")"
			spell_options.append({"name": display_name, "enabled": is_ready, "data": spell})
	
	weapon_selection_menu.show_selection(screen_pos, spell_options, "Select Spell")

func _on_spell_selected(spell_data: SpellData) -> void:
	is_selecting_spell = false
	weapon_selection_menu.hide_menu()
	
	selected_spell = spell_data
	
	# Check if can cast
	if not SpellManager.can_cast_spell(selected_unit.data, selected_spell):
		print("Cannot cast spell")
		_show_action_menu_at_current_position()
		return
	
	# Start target selection for spell
	_start_spell_target_selection()

func _on_spell_selection_cancelled() -> void:
	is_selecting_spell = false
	weapon_selection_menu.hide_menu()
	_show_action_menu_at_current_position()

func _start_spell_target_selection() -> void:
	is_casting_spell = true
	valid_targets.clear()
	target_selection_banner.show_banner()
	
	# Get tiles in spell range (1-2)
	var spell_tiles := get_tiles_in_attack_range(selected_unit.data.coordinate, Enums.AttackRange.RANGE_1_2, selected_unit.data.unit_type)
	var target_coords: Array[Vector2i] = []
	
	for coord in spell_tiles:
		var tile := get_tile(coord)
		# Check if spell can target this tile
		if selected_spell.can_target_enemies() and tile.state == Enums.TileState.ENEMY_UNIT:
			target_coords.append(coord)
			valid_targets.append(tile.occupant)
		elif selected_spell.can_target_allies() and tile.state == Enums.TileState.PLAYER_UNIT:
			target_coords.append(coord)
			valid_targets.append(tile.occupant)
	
	highlight_target_tiles(target_coords)
	
	# Snap cursor to first valid target
	if valid_targets.size() > 0:
		cursor_coord = valid_targets[0].data.coordinate
		grid_cursor.move_to(cursor_coord)
		_handle_cursor_unit_hover(cursor_coord)

func _cancel_spell_target_selection() -> void:
	is_casting_spell = false
	selected_spell = null
	valid_targets.clear()
	clear_target_highlights()
	target_selection_banner.hide_banner()

func _execute_spell_cast(target: Unit) -> void:
	var result := SpellManager.cast_spell(selected_unit.data, target.data, selected_spell, self)
	
	print(selected_unit.data.unit_name, " cast ", selected_spell.spell_name, " on ", target.data.unit_name)
	if result.damage > 0:
		print("Dealt ", result.damage, " damage")
	if result.healing > 0:
		print("Healed ", result.healing, " HP")
	if result.message:
		print(result.message)
	
	# Handle Chain Bolt chain targets
	if result.chain_targets.size() > 0:
		for chain in result.chain_targets:
			print("  Chain: ", chain.target.unit_name, " took ", chain.damage, " damage")
	
	# Clean up and end turn
	_cancel_spell_target_selection()
	selected_spell = null
	selected_unit.set_exhausted()
	_deselect_unit()
	turn_manager.check_player_phase_end()

func _show_action_menu_at_current_position() -> void:
	var screen_pos := _get_menu_screen_position(selected_unit.data.coordinate)
	var can_attack := _check_can_attack_from(selected_unit.data.coordinate)
	action_menu.show_menu_for_unit(screen_pos, can_attack, selected_unit)
