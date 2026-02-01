class_name ItemDatabase
extends Node
## Central database for all consumable items.

enum ItemType { HEALING, STAT_BOOST, STATUS_CURE, ESOTERA_SCROLL }

static var items: Dictionary = {}

static func initialize() -> void:
	# Healing items
	_create_item("Potion", ItemType.HEALING, "Restores 20 HP", _effect_potion)
	_create_item("Hi-Potion", ItemType.HEALING, "Restores 50 HP", _effect_hi_potion)
	_create_item("Elixir", ItemType.HEALING, "Fully restores HP", _effect_elixir)
	
	# Status cure items
	_create_item("Antidote", ItemType.STATUS_CURE, "Cures Poison", _effect_antidote)
	_create_item("Eye Drops", ItemType.STATUS_CURE, "Cures Blind", _effect_eye_drops)
	_create_item("Remedy", ItemType.STATUS_CURE, "Cures all status effects", _effect_remedy)
	
	# Arcane Scrolls (ID 100-116)
	_create_item("Arcane Scroll - Flame Dart", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals fire magic damage, 20% chance to apply Burn", _effect_learn_spell.bind("Flame Dart"))
	_create_item("Arcane Scroll - Aqua Shot", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals water magic damage, 20% chance to apply Slow", _effect_learn_spell.bind("Aqua Shot"))
	_create_item("Arcane Scroll - Stone Spike", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals earth magic damage, 20% chance to apply Break", _effect_learn_spell.bind("Stone Spike"))
	_create_item("Arcane Scroll - Gale Slash", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals wind magic damage, 20% chance to apply Bleed", _effect_learn_spell.bind("Gale Slash"))
	_create_item("Arcane Scroll - Scattervolt", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals lightning magic damage, 20% chance to apply Shock", _effect_learn_spell.bind("Scattervolt"))
	_create_item("Arcane Scroll - Shadow Orb", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals dark magic damage, 20% chance to apply Curse", _effect_learn_spell.bind("Shadow Orb"))
	_create_item("Arcane Scroll - Radiant Ray", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals holy magic damage, 20% chance to apply Blind", _effect_learn_spell.bind("Radiant Ray"))
	_create_item("Arcane Scroll - Soothing Light", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Heals 10 HP from target unit", _effect_learn_spell.bind("Soothing Light"))
	_create_item("Arcane Scroll - Ensnare", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Target unit cannot move during their next phase", _effect_learn_spell.bind("Ensnare"))
	_create_item("Arcane Scroll - Ash Cloud", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Deals fire magic damage, 30% chance to apply Blind", _effect_learn_spell.bind("Ash Cloud"))
	_create_item("Arcane Scroll - Mist Veil", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Increases target unit's DEF by 30%", _effect_learn_spell.bind("Mist Veil"))
	_create_item("Arcane Scroll - Wind Weave", ItemType.ESOTERA_SCROLL, 
		"Learn spell: 50% wind damage, 50% chance to unequip weapon", _effect_learn_spell.bind("Wind Weave"))
	_create_item("Arcane Scroll - Raven's Grip", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Applies Silence to target unit", _effect_learn_spell.bind("Raven's Grip"))
	_create_item("Arcane Scroll - Bestowal", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Transfer item to friendly unit's inventory", _effect_learn_spell.bind("Bestowal"))
	_create_item("Arcane Scroll - Expiate", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Removes status ailment from target unit", _effect_learn_spell.bind("Expiate"))
	_create_item("Arcane Scroll - Chain Bolt", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Lightning damage chains to 2 adjacent enemies", _effect_learn_spell.bind("Chain Bolt"))
	_create_item("Arcane Scroll - Recharge", ItemType.ESOTERA_SCROLL, 
		"Learn spell: Allows exhausted unit to move again", _effect_learn_spell.bind("Recharge"))

static func _create_item(name: String, type: ItemType, description: String, effect_function: Callable) -> void:
	items[name] = {
		"name": name,
		"type": type,
		"description": description,
		"effect": effect_function
	}

static func get_item(name: String) -> Dictionary:
	return items.get(name, {})

static func use_item(item_name: String, target: UnitData) -> String:
	var item := get_item(item_name)
	if item.is_empty():
		return "Item not found"
	
	var effect: Callable = item["effect"]
	return effect.call(target)

# Effect implementations
static func _effect_potion(target: UnitData) -> String:
	if not StatusEffectManager.can_be_healed(target):
		return "%s cannot be healed (Hollow)" % target.unit_name
	
	var old_hp := target.hp_current
	target.hp_current = min(target.hp_max, target.hp_current + 20)
	var healed := target.hp_current - old_hp
	return "Restored %d HP" % healed

static func _effect_hi_potion(target: UnitData) -> String:
	if not StatusEffectManager.can_be_healed(target):
		return "%s cannot be healed (Hollow)" % target.unit_name
	
	var old_hp := target.hp_current
	target.hp_current = min(target.hp_max, target.hp_current + 50)
	var healed := target.hp_current - old_hp
	return "Restored %d HP" % healed

static func _effect_elixir(target: UnitData) -> String:
	if not StatusEffectManager.can_be_healed(target):
		return "%s cannot be healed (Hollow)" % target.unit_name
	
	var old_hp := target.hp_current
	target.hp_current = target.hp_max
	var healed := target.hp_current - old_hp
	return "Fully restored HP (+%d)" % healed

static func _effect_antidote(target: UnitData) -> String:
	if StatusEffectManager.has_status_effect(target, Enums.StatusEffect.POISON):
		StatusEffectManager.remove_status_effect(target, Enums.StatusEffect.POISON)
		return "Cured Poison"
	return "%s is not poisoned" % target.unit_name

static func _effect_eye_drops(target: UnitData) -> String:
	if StatusEffectManager.has_status_effect(target, Enums.StatusEffect.BLIND):
		StatusEffectManager.remove_status_effect(target, Enums.StatusEffect.BLIND)
		return "Cured Blind"
	return "%s is not blinded" % target.unit_name

static func _effect_remedy(target: UnitData) -> String:
	if target.active_status_effects.is_empty():
		return "%s has no status effects" % target.unit_name
	
	StatusEffectManager.clear_all_status_effects(target)
	return "Cured all status effects"

static func _effect_learn_spell(target: UnitData, spell_name: String) -> String:
	if target.has_spell(spell_name):
		return "%s already knows %s" % [target.unit_name, spell_name]
	
	var spell := SpellDatabase.get_spell(spell_name)
	if not spell:
		return "Spell not found: %s" % spell_name
	
	if not SpellDatabase.can_learn_spell_tier(target.class_id, spell.tier):
		return "%s cannot learn %s tier spells" % [target.unit_name, _get_tier_name(spell.tier)]
	
	if target.learn_spell(spell_name):
		return "%s learned %s!" % [target.unit_name, spell_name]
	
	return "Failed to learn %s" % spell_name

static func _get_tier_name(tier: SpellData.SpellTier) -> String:
	match tier:
		SpellData.SpellTier.LOW: return "Low"
		SpellData.SpellTier.MEDIUM: return "Medium"
		SpellData.SpellTier.HIGH: return "High"
	return "Unknown"
