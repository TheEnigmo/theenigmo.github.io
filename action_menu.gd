class_name ActionMenu
extends BaseMenu
## Action menu that appears after unit movement.

func _ready() -> void:
	panel_width = 120
	button_height = 32
	super._ready()

func show_menu_for_unit(screen_position: Vector2, can_attack: bool, unit: Unit) -> void:
	_clear_options()
	
	# Attack
	if can_attack:
		add_option("Attack", "attack", true)
	
	# Spell
	if unit.data.learned_spells.size() > 0 and not StatusEffectManager.has_status_effect(unit.data, Enums.StatusEffect.SILENCE):
		add_option("Spell", "spell", true)
	
	# Active Esotera
	var active_esotera: Array[String] = unit.data.get_active_esotera()
	for esotera_name in active_esotera:
		var can_use: bool = unit.data.can_use_esotera(esotera_name)
		add_option(esotera_name, "esotera_" + esotera_name, can_use)
	
	# Inventory
	add_option("Inventory", "inventory", true)
	
	# Wait
	add_option("Wait", "wait", true)
	
	show_menu(screen_position)
