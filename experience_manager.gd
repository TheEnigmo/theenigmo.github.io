class_name ExperienceManager
extends RefCounted
## Manages experience gain, distribution, and level-up logic.

static func calculate_xp_for_kill(killer: UnitData, enemy: UnitData, is_boss: bool = false) -> int:
	return _calculate_xp(killer, enemy, true, is_boss)

static func calculate_xp_for_participation(participant: UnitData, enemy: UnitData, is_boss: bool = false) -> int:
	return _calculate_xp(participant, enemy, false, is_boss)

static func _calculate_xp(unit: UnitData, enemy: UnitData, is_kill: bool, is_boss: bool) -> int:
	# Base XP = Enemy Level Ã— 10
	var base_xp: int = enemy.level * 10
	
	# Tier Modifier
	var tier_modifier: float = 1.0
	match enemy.tier:
		Enums.Tier.BASE:
			tier_modifier = 1.0
		Enums.Tier.ASCENSION:
			tier_modifier = 1.5
		Enums.Tier.MASTERY:
			tier_modifier = 2.0
	
	# Level Difference Modifier
	var level_diff_modifier: int = 0
	var level_diff: int = enemy.level - unit.level
	if level_diff > 0:
		# Enemy is higher level
		level_diff_modifier = level_diff * 5
	elif level_diff < 0:
		# Enemy is lower level
		level_diff_modifier = level_diff * 3
	
	# Boss Bonus
	var boss_multiplier: float = 2.0 if is_boss else 1.0
	
	# Kill vs Participation
	var kill_participation_modifier: float = 1.0 if is_kill else 0.5
	
	# Final XP = (Base XP Ã— Tier Modifier + Level Difference Modifier) Ã— Boss Bonus Ã— Kill/Participation Modifier
	var final_xp: float = (base_xp * tier_modifier + level_diff_modifier) * boss_multiplier * kill_participation_modifier
	
	# Ensure minimum 1 XP
	return max(1, int(final_xp))

static func get_xp_required_for_level(tier: Enums.Tier, level: int) -> int:
	match tier:
		Enums.Tier.BASE:
			return 100
		Enums.Tier.ASCENSION:
			return 150
		Enums.Tier.MASTERY:
			return 200
	return 100

static func get_total_xp_for_tier(tier: Enums.Tier) -> int:
	match tier:
		Enums.Tier.BASE:
			return 1000  # 10 levels Ã— 100 XP
		Enums.Tier.ASCENSION:
			return 1500  # 10 levels Ã— 150 XP
		Enums.Tier.MASTERY:
			return 3800  # 19 levels Ã— 200 XP
	return 0

static func get_max_level_for_tier(tier: Enums.Tier) -> int:
	match tier:
		Enums.Tier.BASE:
			return 10
		Enums.Tier.ASCENSION:
			return 10
		Enums.Tier.MASTERY:
			return 20
	return 10

static func can_gain_xp(unit: UnitData) -> bool:
	# Mastery tier units at level 20 cannot gain more XP
	return not (unit.tier == Enums.Tier.MASTERY and unit.level >= 20)

static func add_xp(unit: UnitData, xp_gained: int) -> Dictionary:
	# Returns { "leveled_up": bool, "new_level": int, "overflow_xp": int, "evolved": bool, "new_class": String }
	if not can_gain_xp(unit):
		return {"leveled_up": false, "new_level": unit.level, "overflow_xp": 0, "evolved": false, "new_class": ""}
	
	unit.xp_current += xp_gained
	
	var leveled_up := false
	var evolved := false
	var new_class_name := ""
	var max_level := get_max_level_for_tier(unit.tier)
	
	# Check for level up(s)
	while unit.xp_current >= unit.xp_to_next_level:
		# Stop if at max level and not eligible for evolution
		if unit.level >= max_level:
			# Allow one more level for evolution (10â†’11 for Base/Ascension)
			if unit.level == max_level and (unit.tier == Enums.Tier.BASE or unit.tier == Enums.Tier.ASCENSION):
				# Can evolve, proceed with level up
				pass
			else:
				# Max level reached, stop
				unit.xp_current = 0
				unit.xp_to_next_level = 0
				break
		
		unit.xp_current -= unit.xp_to_next_level
		unit.level += 1
		leveled_up = true
		
		# Update XP requirement for next level BEFORE evolution check
		var old_max_level = max_level
		if unit.level < max_level:
			unit.xp_to_next_level = get_xp_required_for_level(unit.tier, unit.level + 1)
		elif unit.level == max_level and (unit.tier == Enums.Tier.BASE or unit.tier == Enums.Tier.ASCENSION):
			# About to evolve, set XP requirement for level 11
			unit.xp_to_next_level = get_xp_required_for_level(unit.tier, unit.level + 1)
		else:
			# Max level reached
			unit.xp_current = 0
			unit.xp_to_next_level = 0
		
		# Check for evolution at level 11 (Base/Ascension tiers only)
		if unit.level == 11 and (unit.tier == Enums.Tier.BASE or unit.tier == Enums.Tier.ASCENSION):
			if can_evolve(unit):
				new_class_name = evolve_unit(unit)
				evolved = true
				max_level = get_max_level_for_tier(unit.tier)  # Update max level for new tier
		
		# Update stats for new level (skip if evolved, as evolve_unit already applied Lv1 stats)
		if not evolved:
			_apply_level_up_stats(unit)
	
	return {
		"leveled_up": leveled_up,
		"new_level": unit.level,
		"overflow_xp": unit.xp_current,
		"evolved": evolved,
		"new_class": new_class_name
	}

static func _apply_level_up_stats(unit: UnitData) -> void:
	# Get new stats from StatsDatabase
	var new_stats := StatsDatabase.get_stats_for_level(unit.class_id, unit.level)
	
	if new_stats.is_empty():
		return
	
	# Store old max HP to calculate healing
	var old_max_hp := unit.hp_max
	
	# Update stats
	unit.hp_max = new_stats["hp"]
	unit.atk = new_stats["atk"]
	unit.def = new_stats["def"]
	unit.spd = new_stats["spd"]
	unit.int_stat = new_stats["int"]
	unit.res = new_stats["res"]
	unit.luk = new_stats["luk"]
	
	# Heal HP proportionally to max HP increase
	var hp_increase := unit.hp_max - old_max_hp
	unit.hp_current = min(unit.hp_max, unit.hp_current + hp_increase)

static func can_evolve(unit: UnitData) -> bool:
	# Check if unit has a promotion target
	var promotion_target = ClassDatabase.get_promotion_target(unit.class_id)
	return promotion_target != null

static func evolve_unit(unit: UnitData) -> String:
	# Get promotion target
	var new_class_id = ClassDatabase.get_promotion_target(unit.class_id)
	if new_class_id == null:
		return ""
	
	# Store old class name for return
	var old_class_name := ClassDatabase.get_class_name(unit.class_id)
	var new_class_name := ClassDatabase.get_class_name(new_class_id)
	
	# Update class and tier
	unit.class_id = new_class_id
	unit.tier = ClassDatabase.get_class_tier(new_class_id)
	
	# Reset to level 1 of new class
	unit.level = 1
	
	# Apply Lv1 stats of new class
	var new_stats := StatsDatabase.get_stats_for_level(unit.class_id, 1)
	if not new_stats.is_empty():
		unit.hp_max = new_stats["hp"]
		unit.atk = new_stats["atk"]
		unit.def = new_stats["def"]
		unit.spd = new_stats["spd"]
		unit.int_stat = new_stats["int"]
		unit.res = new_stats["res"]
		unit.luk = new_stats["luk"]
		# Fully heal on evolution
		unit.hp_current = unit.hp_max
	
	# Reset XP
	unit.xp_current = 0
	unit.xp_to_next_level = get_xp_required_for_level(unit.tier, 2)
	
	# Add innate Esotera for new class
	var new_innate := EsoteraDatabase.get_innate_esotera_for_class(unit.class_id)
	for esotera_name in new_innate:
		if not unit.has_esotera(esotera_name):
			unit.innate_esotera.append(esotera_name)
	
	return new_class_name
