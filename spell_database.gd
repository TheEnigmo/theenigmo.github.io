class_name SpellDatabase
extends Node
## Central database for all spells.

static var spells: Dictionary = {}

static func initialize() -> void:
	# LOW TIER SPELLS
	_create_spell("Flame Dart", Enums.Element.FIRE, SpellData.SpellTier.LOW, 
		"Deals fire magic damage, 20% chance to apply Burn to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.BURN, 0.2)
	
	_create_spell("Aqua Shot", Enums.Element.WATER, SpellData.SpellTier.LOW, 
		"Deals water magic damage, 20% chance to apply Slow to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.SLOW, 0.2)
	
	_create_spell("Stone Spike", Enums.Element.EARTH, SpellData.SpellTier.LOW, 
		"Deals earth magic damage, 20% chance to apply Break to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.BREAK, 0.2)
	
	_create_spell("Gale Slash", Enums.Element.WIND, SpellData.SpellTier.LOW, 
		"Deals wind magic damage, 20% chance to apply Bleed to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.BLEED, 0.2)
	
	_create_spell("Scattervolt", Enums.Element.LIGHTNING, SpellData.SpellTier.LOW, 
		"Deals lightning magic damage, 20% chance to apply Shock to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.SHOCK, 0.2)
	
	_create_spell("Shadow Orb", Enums.Element.DARK, SpellData.SpellTier.LOW, 
		"Deals dark magic damage, 20% chance to apply Curse to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.CURSE, 0.2)
	
	_create_spell("Radiant Ray", Enums.Element.HOLY, SpellData.SpellTier.LOW, 
		"Deals holy magic damage, 20% chance to apply Blind to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.BLIND, 0.2)
	
	_create_spell("Soothing Light", Enums.Element.HOLY, SpellData.SpellTier.LOW, 
		"Heals 10 HP from target unit.", 
		0.0, 1, SpellData.EffectType.HEAL, Enums.StatusEffect.NONE, 0.0, {"heal_amount": 10})
	
	_create_spell("Ensnare", Enums.Element.EARTH, SpellData.SpellTier.LOW, 
		"Target unit is unable to move during their next phase. They may still attack adjacent units.", 
		0.0, 1, SpellData.EffectType.DEBUFF, Enums.StatusEffect.NONE, 0.0, {"ensnare": true})
	
	_create_spell("Ash Cloud", Enums.Element.FIRE, SpellData.SpellTier.LOW, 
		"Deals fire magic damage, 30% chance to apply Blind to target unit.", 
		0.75, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.BLIND, 0.3)
	
	_create_spell("Mist Veil", Enums.Element.WATER, SpellData.SpellTier.LOW, 
		"Increases target unit's DEF by 30%", 
		0.0, 2, SpellData.EffectType.BUFF, Enums.StatusEffect.NONE, 0.0, {"def_buff": 0.3})
	
	_create_spell("Wind Weave", Enums.Element.WIND, SpellData.SpellTier.LOW, 
		"Deals 50% wind magic damage, 50% chance to unequip target unit's weapon.", 
		0.375, 1, SpellData.EffectType.DAMAGE, Enums.StatusEffect.NONE, 0.0, {"unequip_chance": 0.5})
	
	_create_spell("Raven's Grip", Enums.Element.DARK, SpellData.SpellTier.LOW, 
		"Applies Silence to target unit.", 
		0.0, 1, SpellData.EffectType.DEBUFF, Enums.StatusEffect.SILENCE, 1.0)
	
	_create_spell("Bestowal", Enums.Element.HOLY, SpellData.SpellTier.LOW, 
		"Allows user to remotely transfer an item from their inventory into a friendly unit's inventory.", 
		0.0, 1, SpellData.EffectType.UTILITY, Enums.StatusEffect.NONE, 0.0, {"bestowal": true})
	
	# MEDIUM TIER SPELLS
	_create_spell("Expiate", Enums.Element.HOLY, SpellData.SpellTier.MEDIUM, 
		"Removes status ailment from target unit", 
		0.0, 1, SpellData.EffectType.UTILITY, Enums.StatusEffect.NONE, 0.0, {"cleanse": true})
	
	_create_spell("Chain Bolt", Enums.Element.LIGHTNING, SpellData.SpellTier.MEDIUM, 
		"Deals lightning magic damage, strikes through initial target and deals 30% damage to up to 2 more units adjacent to the target.", 
		1.0, 2, SpellData.EffectType.DAMAGE, Enums.StatusEffect.NONE, 0.0, {"chain_damage": 0.3, "chain_count": 2})
	
	# HIGH TIER SPELLS
	_create_spell("Recharge", Enums.Element.LIGHTNING, SpellData.SpellTier.HIGH, 
		"Allows an exhausted unit to move once again.", 
		0.0, 2, SpellData.EffectType.UTILITY, Enums.StatusEffect.NONE, 0.0, {"recharge": true})

static func _create_spell(
	name: String, 
	element: Enums.Element, 
	tier: SpellData.SpellTier,
	description: String,
	damage_mult: float,
	cooldown: int,
	effect_type: SpellData.EffectType,
	status_effect: Enums.StatusEffect = Enums.StatusEffect.NONE,
	status_chance: float = 0.0,
	special_props: Dictionary = {}
) -> void:
	var spell := SpellData.new(
		name, element, tier, description, damage_mult, cooldown, 
		effect_type, status_effect, status_chance, special_props
	)
	spells[name] = spell

static func get_spell(spell_name: String) -> SpellData:
	return spells.get(spell_name, null)

static func can_learn_spell_tier(class_id: Enums.ClassID, tier: SpellData.SpellTier) -> bool:
	match tier:
		SpellData.SpellTier.LOW:
			return class_id in [
				Enums.ClassID.CAPTAIN, Enums.ClassID.VANGUARD, Enums.ClassID.HERO,
				Enums.ClassID.MAGE, Enums.ClassID.SAGE, Enums.ClassID.SUMMONER,
				Enums.ClassID.CLERIC, Enums.ClassID.BISHOP, Enums.ClassID.PALADIN
			]
		SpellData.SpellTier.MEDIUM:
			return class_id in [
				Enums.ClassID.HERO, Enums.ClassID.MAGE, Enums.ClassID.SAGE, 
				Enums.ClassID.SUMMONER, Enums.ClassID.CLERIC, Enums.ClassID.BISHOP, 
				Enums.ClassID.PALADIN
			]
		SpellData.SpellTier.HIGH:
			return class_id in [
				Enums.ClassID.SAGE, Enums.ClassID.SUMMONER, 
				Enums.ClassID.BISHOP, Enums.ClassID.PALADIN
			]
	return false
