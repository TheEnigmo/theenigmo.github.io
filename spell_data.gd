class_name SpellData
extends Resource
## Data container for spell properties.

enum SpellTier { LOW, MEDIUM, HIGH }
enum EffectType { DAMAGE, HEAL, BUFF, DEBUFF, UTILITY }

@export var spell_name: String
@export var element: Enums.Element
@export var tier: SpellTier
@export var description: String
@export var damage_multiplier: float  # 0.75 for LOW, 1.0 for MEDIUM, 1.25 for HIGH
@export var cooldown_duration: int
@export var effect_type: EffectType
@export var status_effect: Enums.StatusEffect = Enums.StatusEffect.NONE
@export var status_chance: float = 0.0  # 0.0 to 1.0
@export var special_properties: Dictionary = {}  # For unique mechanics like Chain Bolt, Mist Veil, etc.

func _init(
	p_spell_name: String = "",
	p_element: Enums.Element = Enums.Element.NONE,
	p_tier: SpellTier = SpellTier.LOW,
	p_description: String = "",
	p_damage_multiplier: float = 0.75,
	p_cooldown_duration: int = 1,
	p_effect_type: EffectType = EffectType.DAMAGE,
	p_status_effect: Enums.StatusEffect = Enums.StatusEffect.NONE,
	p_status_chance: float = 0.0,
	p_special_properties: Dictionary = {}
) -> void:
	spell_name = p_spell_name
	element = p_element
	tier = p_tier
	description = p_description
	damage_multiplier = p_damage_multiplier
	cooldown_duration = p_cooldown_duration
	effect_type = p_effect_type
	status_effect = p_status_effect
	status_chance = p_status_chance
	special_properties = p_special_properties

func can_target_allies() -> bool:
	return effect_type in [EffectType.HEAL, EffectType.BUFF, EffectType.UTILITY]

func can_target_enemies() -> bool:
	return effect_type in [EffectType.DAMAGE, EffectType.DEBUFF]
