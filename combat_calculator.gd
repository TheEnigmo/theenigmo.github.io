class_name CombatCalculator
extends RefCounted
## Handles all combat calculations.

static func calculate_physical_damage(attacker: UnitData, defender: UnitData) -> int:
	var base_damage: int = attacker.get_effective_atk() - defender.get_effective_def()
	base_damage = max(0, base_damage)
	
	var modifier: float = get_class_matchup_modifier(attacker.class_id, defender.class_id)
	var final_damage: float = base_damage * (1.0 + modifier)
	
	return int(ceil(final_damage)) if final_damage > 0 else 0

static func calculate_magic_damage(attacker: UnitData, defender: UnitData) -> int:
	var base_damage: int = attacker.get_effective_int() - defender.get_effective_res()
	base_damage = max(0, base_damage)
	
	var modifier: float = get_class_matchup_modifier(attacker.class_id, defender.class_id)
	var final_damage: float = base_damage * (1.0 + modifier)
	
	return int(ceil(final_damage)) if final_damage > 0 else 0

static func get_class_matchup_modifier(attacker_class: Enums.ClassID, defender_class: Enums.ClassID) -> float:
	var matrix := {
		Enums.ClassID.CAPTAIN: {Enums.ClassID.WARRIOR: 0.1, Enums.ClassID.ARCHER: 0.1, Enums.ClassID.GUARDIAN: 0.1, Enums.ClassID.LANCER: -0.1, Enums.ClassID.MAGE: -0.1, Enums.ClassID.CLERIC: -0.1},
		Enums.ClassID.DUELIST: {Enums.ClassID.WARRIOR: 0.1, Enums.ClassID.ROGUE: 0.1, Enums.ClassID.STRIKER: 0.1, Enums.ClassID.LANCER: -0.1, Enums.ClassID.ARCHER: -0.1, Enums.ClassID.GUARDIAN: -0.1},
		Enums.ClassID.LANCER: {Enums.ClassID.CAPTAIN: 0.1, Enums.ClassID.DUELIST: 0.1, Enums.ClassID.ARCHER: 0.1, Enums.ClassID.WARRIOR: -0.1, Enums.ClassID.MAGE: -0.1, Enums.ClassID.CLERIC: -0.1},
		Enums.ClassID.WARRIOR: {Enums.ClassID.LANCER: 0.1, Enums.ClassID.ARCHER: 0.1, Enums.ClassID.CLERIC: 0.1, Enums.ClassID.CAPTAIN: -0.1, Enums.ClassID.DUELIST: -0.1, Enums.ClassID.ROGUE: -0.1},
		Enums.ClassID.ARCHER: {Enums.ClassID.DUELIST: 0.1, Enums.ClassID.ROGUE: 0.1, Enums.ClassID.MAGE: 0.1, Enums.ClassID.STRIKER: 0.1, Enums.ClassID.CAPTAIN: -0.1, Enums.ClassID.LANCER: -0.1, Enums.ClassID.WARRIOR: -0.1, Enums.ClassID.GUARDIAN: -0.1},
		Enums.ClassID.GUARDIAN: {Enums.ClassID.DUELIST: 0.1, Enums.ClassID.ARCHER: 0.1, Enums.ClassID.STRIKER: 0.1, Enums.ClassID.CAPTAIN: -0.1, Enums.ClassID.MAGE: -0.1, Enums.ClassID.CLERIC: -0.1},
		Enums.ClassID.ROGUE: {Enums.ClassID.WARRIOR: 0.1, Enums.ClassID.MAGE: 0.1, Enums.ClassID.CLERIC: 0.1, Enums.ClassID.DUELIST: -0.1, Enums.ClassID.ARCHER: -0.1, Enums.ClassID.STRIKER: -0.1},
		Enums.ClassID.MAGE: {Enums.ClassID.CAPTAIN: 0.1, Enums.ClassID.LANCER: 0.1, Enums.ClassID.GUARDIAN: 0.1, Enums.ClassID.ARCHER: -0.1, Enums.ClassID.ROGUE: -0.1, Enums.ClassID.STRIKER: -0.1},
		Enums.ClassID.CLERIC: {Enums.ClassID.CAPTAIN: 0.1, Enums.ClassID.LANCER: 0.1, Enums.ClassID.GUARDIAN: 0.1, Enums.ClassID.WARRIOR: -0.1, Enums.ClassID.ROGUE: -0.1, Enums.ClassID.STRIKER: -0.1},
		Enums.ClassID.STRIKER: {Enums.ClassID.ROGUE: 0.1, Enums.ClassID.MAGE: 0.1, Enums.ClassID.CLERIC: 0.1, Enums.ClassID.DUELIST: -0.1, Enums.ClassID.ARCHER: -0.1, Enums.ClassID.GUARDIAN: -0.1}
	}
	
	if matrix.has(attacker_class) and matrix[attacker_class].has(defender_class):
		return matrix[attacker_class][defender_class]
	return 0.0

static func calculate_hit_chance(attacker: UnitData, defender: UnitData) -> float:
	var hit: float = Constants.BASE_HIT_CHANCE - (defender.get_effective_spd() * Constants.SPD_HIT_MODIFIER)
	hit += StatusEffectManager.get_hit_rate_modifier(attacker)
	return clamp(hit, 0.0, 1.0)

static func calculate_crit_chance(attacker: UnitData) -> float:
	var crit: float = attacker.get_effective_luk() * Constants.CRIT_LUK_MODIFIER
	return clamp(crit, 0.0, 1.0)

static func can_double_attack(attacker: UnitData, defender: UnitData) -> bool:
	return attacker.get_effective_spd() >= defender.get_effective_spd() + Constants.DOUBLE_ATTACK_SPD_THRESHOLD

static func can_counterattack(counter_unit: UnitData, _attacker: UnitData, distance: int) -> bool:
	if not StatusEffectManager.can_counterattack(counter_unit):
		return false
	
	match counter_unit.get_attack_range():
		Enums.AttackRange.RANGE_0:
			return false
		Enums.AttackRange.RANGE_1:
			return distance == 1
		Enums.AttackRange.RANGE_2:
			return distance == 2
		Enums.AttackRange.RANGE_1_2:
			return distance == 1 or distance == 2
	return false

static func roll_hit(hit_chance: float) -> bool:
	return randf() <= hit_chance

static func roll_crit(crit_chance: float) -> bool:
	return randf() <= crit_chance

static func apply_damage(target: UnitData, damage: int, is_crit: bool) -> int:
	var final_damage: int = damage
	if is_crit:
		final_damage = int(ceil(damage * Constants.CRIT_DAMAGE_MULTIPLIER))
	
	# Apply status effect damage modifiers (Hex)
	final_damage = int(ceil(final_damage * StatusEffectManager.get_damage_taken_modifier(target)))
	
	target.hp_current = max(0, target.hp_current - final_damage)
	return final_damage
