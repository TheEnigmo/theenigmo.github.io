class_name ItemSlotActionMenu
extends BaseMenu
## Displays actions for selected equipment/item slots.

func _ready() -> void:
	panel_width = 120
	button_height = 32
	super._ready()

func show_equipment_menu(screen_position: Vector2, is_equipped: bool, is_shield: bool) -> void:
	_clear_options()
	
	if is_equipped:
		add_option("Unequip", "unequip", true)
	else:
		add_option("Equip", "equip", true)
	
	add_option("Discard", "discard", true)
	
	show_menu(screen_position)

func show_item_menu(screen_position: Vector2, unit: UnitData = null, item_name: String = "") -> void:
	_clear_options()
	
	var can_use := true
	# Check if this is an Arcane Scroll and unit already knows the spell
	if item_name.begins_with("Arcane Scroll - ") and unit:
		var spell_name := item_name.trim_prefix("Arcane Scroll - ")
		if unit.has_spell(spell_name):
			can_use = false
	
	add_option("Use", "use", can_use)
	add_option("Discard", "discard", true)
	
	show_menu(screen_position)
