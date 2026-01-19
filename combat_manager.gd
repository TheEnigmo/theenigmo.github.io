class_name CombatManager
extends Node
## Manages combat flow between units.

signal combat_finished
signal unit_died(unit: Unit)
signal damage_dealt(attacker: Unit, defender: Unit, damage: int, is_crit: bool)
signal xp_gained(unit: Unit, xp_amount: int, leveled_up: bool, new_level: int)

var grid: Grid
var combat_ui: CombatUI
var participants: Array[Unit] = []  # Track all units that dealt damage

func setup(grid_ref: Grid) -> void:
	grid = grid_ref
	# Setup combat UI
	combat_ui = preload("res://scenes/combat_ui.tscn").instantiate()
	add_child(combat_ui)

func execute_combat(attacker: Unit, defender: Unit) -> void:
	if attacker == null or defender == null:
		combat_finished.emit()
		return
	
	# Reset combat tracking
	participants.clear()
	attacker.data.damage_dealt_this_combat = 0
	defender.data.damage_dealt_this_combat = 0
	
	combat_ui.show_combat(attacker, defender)
	await get_tree().create_timer(0.5).timeout
	
	var distance: int = grid.get_manhattan_distance(attacker.data.coordinate, defender.data.coordinate)
	
	_perform_attack(attacker, defender)
	if attacker.data.damage_dealt_this_combat > 0:
		participants.append(attacker)
	await get_tree().create_timer(0.5).timeout
	
	if not defender.data.is_alive():
		await _handle_unit_death(defender, attacker)
		return
	
	if CombatCalculator.can_counterattack(defender.data, attacker.data, distance):
		_perform_attack(defender, attacker)
		if defender.data.damage_dealt_this_combat > 0 and not participants.has(defender):
			participants.append(defender)
		await get_tree().create_timer(0.5).timeout
		
		if not attacker.data.is_alive():
			await _handle_unit_death(attacker, defender)
			return
	
	if CombatCalculator.can_double_attack(attacker.data, defender.data):
		_perform_attack(attacker, defender)
		await get_tree().create_timer(0.5).timeout
		
		if not defender.data.is_alive():
			await _handle_unit_death(defender, attacker)
			return
	
	# Award participation XP if any player units dealt damage to an enemy (even if enemy survived)
	var has_player_participants := false
	var enemy_unit: UnitData = null
	
	# Determine which unit is the enemy and if there are player participants
	if defender.data.unit_type == Enums.UnitType.ENEMY:
		enemy_unit = defender.data
	elif attacker.data.unit_type == Enums.UnitType.ENEMY:
		enemy_unit = attacker.data
	
	# Check if any participants are players who dealt damage
	for participant in participants:
		if participant.data.unit_type == Enums.UnitType.PLAYER and participant.data.damage_dealt_this_combat > 0:
			has_player_participants = true
			break
	
	# Distribute participation XP if enemy survived but players dealt damage
	if enemy_unit != null and enemy_unit.is_alive() and has_player_participants:
		await _distribute_participation_xp(enemy_unit)
	
	await get_tree().create_timer(0.5).timeout
	await combat_ui.fade_out()
	combat_finished.emit()

func _handle_unit_death(dead_unit: Unit, killer: Unit) -> void:
	unit_died.emit(dead_unit)
	
	# Distribute XP if dead unit is an enemy
	if dead_unit.data.unit_type == Enums.UnitType.ENEMY:
		await _distribute_xp(dead_unit.data, killer)
	
	await combat_ui.fade_out()
	combat_finished.emit()

func _distribute_xp(enemy: UnitData, killer: Unit) -> void:
	var is_boss := false  # TODO: Add boss flag to UnitData
	
	# Award kill XP to killer
	if killer.data.unit_type == Enums.UnitType.PLAYER:
		if ExperienceManager.can_gain_xp(killer.data):
			var kill_xp := ExperienceManager.calculate_xp_for_kill(killer.data, enemy, is_boss)
			await _award_xp_to_unit(killer, kill_xp)
	
	# Award participation XP to other participants
	for participant in participants:
		if participant != killer and participant.data.unit_type == Enums.UnitType.PLAYER:
			if participant.data.damage_dealt_this_combat > 0 and ExperienceManager.can_gain_xp(participant.data):
				var participation_xp := ExperienceManager.calculate_xp_for_participation(participant.data, enemy, is_boss)
				await _award_xp_to_unit(participant, participation_xp)

func _distribute_participation_xp(enemy: UnitData) -> void:
	var is_boss := false  # TODO: Add boss flag to UnitData
	
	# Award participation XP to all player participants who dealt damage
	for participant in participants:
		if participant.data.unit_type == Enums.UnitType.PLAYER:
			if participant.data.damage_dealt_this_combat > 0 and ExperienceManager.can_gain_xp(participant.data):
				var participation_xp := ExperienceManager.calculate_xp_for_participation(participant.data, enemy, is_boss)
				await _award_xp_to_unit(participant, participation_xp)

func _award_xp_to_unit(unit: Unit, xp_amount: int) -> void:
	var result := ExperienceManager.add_xp(unit.data, xp_amount)
	
	# Animate XP bar in combat UI (1 second delay after damage)
	await get_tree().create_timer(1.0).timeout
	await combat_ui.animate_xp_gain(unit, xp_amount, unit.data.xp_current, unit.data.xp_to_next_level)
	
	# Show XP gain floating text
	await _show_xp_gain(unit, xp_amount)
	
	# Emit signal for any listeners
	xp_gained.emit(unit, xp_amount, result["leveled_up"], result["new_level"])
	
	# Show level up notification if applicable
	if result["leveled_up"]:
		await _show_level_up(unit, result["new_level"], result.get("evolved", false), result.get("new_class", ""))

func _show_xp_gain(unit: Unit, xp_amount: int) -> void:
	var xp_label := Label.new()
	xp_label.text = "+%d XP" % xp_amount
	xp_label.add_theme_font_size_override("font_size", 20)
	xp_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))  # Yellow
	xp_label.position = Vector2(unit.position.x - 30, unit.position.y - 40)
	xp_label.z_index = 202
	grid.add_child(xp_label)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(xp_label, "position:y", xp_label.position.y - 30, 1.0)
	tween.tween_property(xp_label, "modulate:a", 0.0, 1.0)
	await tween.finished
	xp_label.queue_free()

func _show_level_up(unit: Unit, new_level: int, evolved: bool, new_class: String) -> void:
	var level_up_label := Label.new()
	
	# Determine text and color based on evolution
	if evolved:
		# Get the tier to determine message
		if unit.data.tier == Enums.Tier.ASCENSION:
			level_up_label.text = "ASCENSION!"
		elif unit.data.tier == Enums.Tier.MASTERY:
			level_up_label.text = "MASTERY!"
		else:
			level_up_label.text = "EVOLVED!"
		level_up_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.9))  # Light teal
	else:
		level_up_label.text = "LEVEL UP!"
		level_up_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))  # Green
	
	level_up_label.add_theme_font_size_override("font_size", 24)
	level_up_label.position = Vector2(unit.position.x - 50, unit.position.y - 20)
	level_up_label.z_index = 203
	grid.add_child(level_up_label)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(level_up_label, "position:y", level_up_label.position.y - 40, 1.5)
	tween.tween_property(level_up_label, "modulate:a", 0.0, 1.5)
	await tween.finished
	level_up_label.queue_free()
	
	if evolved:
		print("%s evolved into %s!" % [unit.data.unit_name, new_class])
	else:
		print("%s leveled up to level %d!" % [unit.data.unit_name, new_level])

func _perform_attack(attacker: Unit, defender: Unit) -> void:
	var hit_chance: float = CombatCalculator.calculate_hit_chance(attacker.data, defender.data)
	
	if not CombatCalculator.roll_hit(hit_chance):
		combat_ui.show_miss(defender)
		damage_dealt.emit(attacker, defender, 0, false)
		return
	
	var damage: int
	if attacker.data.uses_magic():
		damage = CombatCalculator.calculate_magic_damage(attacker.data, defender.data)
	else:
		damage = CombatCalculator.calculate_physical_damage(attacker.data, defender.data)
	
	var crit_chance: float = CombatCalculator.calculate_crit_chance(attacker.data)
	var is_crit: bool = CombatCalculator.roll_crit(crit_chance)
	
	var final_damage: int = CombatCalculator.apply_damage(defender.data, damage, is_crit)
	
	# Track damage for XP participation
	attacker.data.damage_dealt_this_combat += final_damage
	
	combat_ui.animate_damage(defender, defender.data.hp_current, final_damage, is_crit)
	damage_dealt.emit(attacker, defender, final_damage, is_crit)
	
	# Apply weapon status effects on hit
	if attacker.data.equipped_weapon and attacker.data.equipped_weapon.applies_status_effect != Enums.StatusEffect.NONE:
		var weapon := attacker.data.equipped_weapon
		if randf() <= weapon.status_effect_chance:
			StatusEffectManager.apply_status_effect(
				defender.data,
				weapon.applies_status_effect,
				weapon.status_effect_duration,
				attacker.data
			)
			var effect_name := StatusEffectManager.get_effect_name(weapon.applies_status_effect)
			print("%s applied %s to %s!" % [attacker.data.unit_name, effect_name, defender.data.unit_name])
			
			# Show status application animation (wait for damage animation to finish)
			await get_tree().create_timer(0.5).timeout
			show_status_application(defender, weapon.applies_status_effect)

func show_status_application(target: Unit, effect: Enums.StatusEffect) -> void:
	var effect_name := StatusEffectManager.get_effect_name(effect)
	
	# Determine which combat UI panel to use for positioning
	var is_friendly := target.data.unit_type == Enums.UnitType.PLAYER
	var panel: PanelContainer = combat_ui.friendly_panel if is_friendly else combat_ui.enemy_panel
	
	# Create status application label
	var status_label := Label.new()
	status_label.text = effect_name + "!"
	status_label.add_theme_font_size_override("font_size", 28)
	status_label.add_theme_color_override("font_color", _get_status_color(effect))
	
	# Position same as Miss/Crit (near combat UI panel)
	status_label.position = Vector2(panel.position.x + 100, panel.position.y - 50)
	status_label.z_index = 200
	combat_ui.add_child(status_label)
	
	# Animate: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(status_label, "position:y", status_label.position.y - 30, 0.8)
	tween.tween_property(status_label, "modulate:a", 0.0, 0.8)
	await tween.finished
	status_label.queue_free()

func show_status_proc_effect(target: Unit, effect: Enums.StatusEffect, damage: int = 0) -> void:
	var effect_name := StatusEffectManager.get_effect_name(effect)
	
	# Create proc label
	var proc_label := Label.new()
	proc_label.text = effect_name
	proc_label.add_theme_font_size_override("font_size", 24)
	proc_label.add_theme_color_override("font_color", _get_status_color(effect))
	
	# Position dynamically below unit (use position not global_position since adding to grid)
	proc_label.position = Vector2(target.position.x - 40, target.position.y + 40)
	proc_label.z_index = 202
	grid.add_child(proc_label)
	
	# Animate proc label
	var proc_tween := create_tween()
	proc_tween.set_parallel(true)
	proc_tween.tween_property(proc_label, "position:y", proc_label.position.y - 30, 0.8)
	proc_tween.tween_property(proc_label, "modulate:a", 0.0, 0.8)
	proc_tween.finished.connect(proc_label.queue_free)
	
	# If damage was dealt, show damage number and HP bar
	if damage > 0:
		await get_tree().create_timer(0.1).timeout
		_show_status_damage(target, damage)

func _show_status_damage(target: Unit, damage: int) -> void:
	# Create damage label
	var damage_label := Label.new()
	damage_label.text = str(damage)
	damage_label.add_theme_font_size_override("font_size", 28)
	damage_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	# Position dynamically based on unit's position (not global_position)
	damage_label.position = Vector2(target.position.x - 15, target.position.y + 5)
	damage_label.z_index = 201
	grid.add_child(damage_label)
	
	# Animate damage number
	var damage_tween := create_tween()
	damage_tween.set_parallel(true)
	damage_tween.tween_property(damage_label, "position:y", damage_label.position.y - 25, 0.8)
	damage_tween.tween_property(damage_label, "modulate:a", 0.0, 0.8)
	damage_tween.finished.connect(damage_label.queue_free)
	
	# Show HP bar below unit
	_show_unit_hp_bar(target)

func _show_unit_hp_bar(target: Unit) -> void:
	# Create HP bar container
	var hp_container := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	hp_container.add_theme_stylebox_override("panel", style)
	# Position dynamically based on unit's position (not global_position)
	hp_container.position = Vector2(target.position.x - 30, target.position.y + 35)
	hp_container.z_index = 201
	grid.add_child(hp_container)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	hp_container.add_child(vbox)
	
	# HP bar
	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(60, 8)
	hp_bar.max_value = target.data.hp_max
	hp_bar.value = target.data.hp_current
	hp_bar.show_percentage = false
	
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.0, 0.0)
	hp_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.0, 0.8, 0.0)
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	
	vbox.add_child(hp_bar)
	
	# HP label
	var hp_label := Label.new()
	hp_label.text = "%d/%d" % [target.data.hp_current, target.data.hp_max]
	hp_label.add_theme_font_size_override("font_size", 10)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hp_label)
	
	# Fade out after delay
	await get_tree().create_timer(1.5).timeout
	var fade_tween := create_tween()
	fade_tween.tween_property(hp_container, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	hp_container.queue_free()

func _get_status_color(effect: Enums.StatusEffect) -> Color:
	match effect:
		Enums.StatusEffect.BLEED: return Color(0.8, 0.1, 0.1)
		Enums.StatusEffect.BLIND: return Color(0.3, 0.3, 0.3)
		Enums.StatusEffect.BREAK: return Color(0.7, 0.5, 0.3)
		Enums.StatusEffect.BURN: return Color(1.0, 0.5, 0.0)
		Enums.StatusEffect.CURSE: return Color(0.5, 0.0, 0.5)
		Enums.StatusEffect.DECAY: return Color(0.4, 0.3, 0.2)
		Enums.StatusEffect.DRAIN: return Color(0.6, 0.0, 0.6)
		Enums.StatusEffect.FREEZE: return Color(0.5, 0.8, 1.0)
		Enums.StatusEffect.HEX: return Color(0.3, 0.0, 0.3)
		Enums.StatusEffect.HOLLOW: return Color(0.2, 0.2, 0.2)
		Enums.StatusEffect.POISON: return Color(0.2, 0.8, 0.2)
		Enums.StatusEffect.SHOCK: return Color(1.0, 1.0, 0.0)
		Enums.StatusEffect.SILENCE: return Color(0.4, 0.4, 0.6)
		Enums.StatusEffect.SLOW: return Color(0.5, 0.5, 0.8)
		Enums.StatusEffect.VOID: return Color(0.1, 0.1, 0.5)
	return Color.WHITE
