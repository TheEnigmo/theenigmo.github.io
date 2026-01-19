class_name CombatUI
extends CanvasLayer

@onready var friendly_panel: PanelContainer = $FriendlyPanel
@onready var friendly_name: Label = $FriendlyPanel/MarginContainer/VBoxContainer/FriendlyNameLabel
@onready var friendly_hp_bar: ProgressBar = $FriendlyPanel/MarginContainer/VBoxContainer/FriendlyHPContainer/FriendlyHPBar
@onready var friendly_hp_label: Label = $FriendlyPanel/MarginContainer/VBoxContainer/FriendlyHPContainer/FriendlyHPLabel
@onready var friendly_xp_bar: ProgressBar = $FriendlyPanel/MarginContainer/VBoxContainer/FriendlyXPContainer/FriendlyXPBar
@onready var friendly_xp_label: Label = $FriendlyPanel/MarginContainer/VBoxContainer/FriendlyXPContainer/FriendlyXPLabel

@onready var enemy_panel: PanelContainer = $EnemyPanel
@onready var enemy_name: Label = $EnemyPanel/MarginContainer/VBoxContainer/EnemyNameLabel
@onready var enemy_hp_bar: ProgressBar = $EnemyPanel/MarginContainer/VBoxContainer/EnemyHPContainer/EnemyHPBar
@onready var enemy_hp_label: Label = $EnemyPanel/MarginContainer/VBoxContainer/EnemyHPContainer/EnemyHPLabel
@onready var enemy_xp_bar: ProgressBar = $EnemyPanel/MarginContainer/VBoxContainer/EnemyXPContainer/EnemyXPBar
@onready var enemy_xp_label: Label = $EnemyPanel/MarginContainer/VBoxContainer/EnemyXPContainer/EnemyXPLabel

var current_attacker: Unit
var current_defender: Unit

func _ready() -> void:
	hide_ui()

func show_combat(attacker: Unit, defender: Unit) -> void:
	current_attacker = attacker
	current_defender = defender
	
	# Determine which is friendly
	if attacker.data.unit_type == Enums.UnitType.PLAYER:
		_setup_panel(friendly_panel, friendly_name, friendly_hp_bar, friendly_hp_label, attacker)
		_setup_panel(enemy_panel, enemy_name, enemy_hp_bar, enemy_hp_label, defender)
	else:
		_setup_panel(enemy_panel, enemy_name, enemy_hp_bar, enemy_hp_label, attacker)
		_setup_panel(friendly_panel, friendly_name, friendly_hp_bar, friendly_hp_label, defender)
	
	_fade_in()

func _setup_panel(panel: PanelContainer, name_label: Label, hp_bar: ProgressBar, hp_label: Label, unit: Unit) -> void:
	name_label.text = unit.data.unit_name
	hp_bar.max_value = unit.data.hp_max
	hp_bar.value = unit.data.hp_current
	hp_label.text = "HP: %d/%d" % [unit.data.hp_current, unit.data.hp_max]
	panel.modulate.a = 0.0
	
	# Setup XP bar
	var xp_bar: ProgressBar
	var xp_label: Label
	if unit.data.unit_type == Enums.UnitType.PLAYER:
		if panel == friendly_panel:
			xp_bar = friendly_xp_bar
			xp_label = friendly_xp_label
		else:
			xp_bar = enemy_xp_bar
			xp_label = enemy_xp_label
		
		xp_bar.max_value = unit.data.xp_to_next_level
		xp_bar.value = unit.data.xp_current
		xp_label.text = "XP: %d/%d" % [unit.data.xp_current, unit.data.xp_to_next_level]
		xp_bar.visible = true
		xp_label.visible = true
	else:
		# Hide XP bar for enemy units
		if panel == friendly_panel:
			friendly_xp_bar.visible = false
			friendly_xp_label.visible = false
		else:
			enemy_xp_bar.visible = false
			enemy_xp_label.visible = false

func animate_damage(target: Unit, new_hp: int, damage: int, is_crit: bool) -> void:
	var is_friendly := target.data.unit_type == Enums.UnitType.PLAYER
	var hp_bar: ProgressBar = friendly_hp_bar if is_friendly else enemy_hp_bar
	var hp_label: Label = friendly_hp_label if is_friendly else enemy_hp_label
	
	show_damage_number(target, damage, is_crit)
	
	var tween := create_tween()
	tween.tween_property(hp_bar, "value", new_hp, 0.3)
	tween.tween_callback(func(): hp_label.text = "HP: %d/%d" % [new_hp, target.data.hp_max])

func show_damage_number(target: Unit, damage: int, is_crit: bool) -> void:
	var is_friendly := target.data.unit_type == Enums.UnitType.PLAYER
	var panel: PanelContainer = friendly_panel if is_friendly else enemy_panel
	
	# Create damage label
	var damage_label := Label.new()
	if is_crit:
		damage_label.text = str(damage)
		damage_label.add_theme_font_size_override("font_size", 40)
		damage_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		damage_label.text = str(damage)
		damage_label.add_theme_font_size_override("font_size", 32)
		damage_label.add_theme_color_override("font_color", Color.WHITE)
	
	damage_label.position = Vector2(panel.position.x + 100, panel.position.y - 50)
	damage_label.z_index = 200
	add_child(damage_label)
	
	# Create CRIT label if critical
	if is_crit:
		var crit_label := Label.new()
		crit_label.text = "CRIT!"
		crit_label.add_theme_font_size_override("font_size", 24)
		crit_label.add_theme_color_override("font_color", Color.RED)
		crit_label.position = Vector2(panel.position.x + 100, panel.position.y - 80)
		crit_label.z_index = 200
		add_child(crit_label)
		
		# Animate crit label
		var crit_tween := create_tween()
		crit_tween.set_parallel(true)
		crit_tween.tween_property(crit_label, "position:y", crit_label.position.y - 30, 0.8)
		crit_tween.tween_property(crit_label, "modulate:a", 0.0, 0.8)
		crit_tween.finished.connect(crit_label.queue_free)
	
	# Animate damage number: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 30, 0.8)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.8)
	await tween.finished
	damage_label.queue_free()

func show_miss(target: Unit) -> void:
	var is_friendly := target.data.unit_type == Enums.UnitType.PLAYER
	var panel: PanelContainer = friendly_panel if is_friendly else enemy_panel
	
	# Create miss label
	var miss_label := Label.new()
	miss_label.text = "MISS"
	miss_label.add_theme_font_size_override("font_size", 32)
	miss_label.add_theme_color_override("font_color", Color.GRAY)
	miss_label.position = Vector2(panel.position.x + 100, panel.position.y - 50)
	miss_label.z_index = 200
	add_child(miss_label)
	
	# Animate: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(miss_label, "position:y", miss_label.position.y - 30, 0.8)
	tween.tween_property(miss_label, "modulate:a", 0.0, 0.8)
	await tween.finished
	miss_label.queue_free()

func hide_ui() -> void:
	friendly_panel.visible = false
	enemy_panel.visible = false

func animate_xp_gain(unit: Unit, xp_gained: int, new_xp: int, new_max_xp: int) -> void:
	var is_friendly := unit.data.unit_type == Enums.UnitType.PLAYER
	var xp_bar: ProgressBar = friendly_xp_bar if is_friendly else enemy_xp_bar
	var xp_label: Label = friendly_xp_label if is_friendly else enemy_xp_label
	
	# Update max value in case of level up
	xp_bar.max_value = new_max_xp
	
	var tween := create_tween()
	tween.tween_property(xp_bar, "value", new_xp, 1.0)
	tween.tween_callback(func(): xp_label.text = "XP: %d/%d" % [new_xp, new_max_xp])
	await tween.finished

func _fade_in() -> void:
	friendly_panel.visible = true
	enemy_panel.visible = true
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(friendly_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(enemy_panel, "modulate:a", 1.0, 0.3)

func fade_out() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(friendly_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(enemy_panel, "modulate:a", 0.0, 0.3)
	await tween.finished
	hide_ui()
