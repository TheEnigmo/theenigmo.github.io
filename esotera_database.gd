class_name EsoteraDatabase
extends Node
## Central database for all Esotera definitions.

enum EsoteraType { ACTIVE, PASSIVE }
enum EsoteraSource { INNATE, DISCOVERED }

static var esotera: Dictionary = {}

static func initialize() -> void:
	# War Cry - Hero only
	_add_esotera(
		"War Cry",
		"Units in a 3x3 radius around the user gain 10% increase to all stats until the end of the enemy's next phase",
		EsoteraType.ACTIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.HERO]
	)
	
	# Smokescreen - Shinobi only
	_add_esotera(
		"Smokescreen",
		"Applies a smokescreen in 3x3 area around user which applies Blind to enemy units. Usable once per floor.",
		EsoteraType.ACTIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.SHINOBI]
	)
	
	# Splitshot - Hunter only
	_add_esotera(
		"Splitshot",
		"Grants ability to attack multiple targets in one turn at 50% damage each.",
		EsoteraType.ACTIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.HUNTER]
	)
	
	# Summon - Summoner only
	_add_esotera(
		"Summon",
		"Grants ability to summon a unit to fight with the party.",
		EsoteraType.ACTIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.SUMMONER]
	)
	
	# Salvation - Paladin only
	_add_esotera(
		"Salvation",
		"User can trade positions with another friendly unit. Usable once per floor.",
		EsoteraType.ACTIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.PALADIN]
	)
	
	# Riposte - Kensei only
	_add_esotera(
		"Riposte",
		"Guaranteed critical hit after a dodge.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.KENSEI]
	)
	
	# Ambidextrous - Swordmaster, Kensei
	_add_esotera(
		"Ambidextrous",
		"Able to simultaneously wield 2 one-handed weapons. If 2 weapons are equipped, guarantees 2 hits per combat instance, lowers SPD by 25%.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.SWORDMASTER, Enums.ClassID.KENSEI]
	)
	
	# Eclipse - Dragoon only
	_add_esotera(
		"Eclipse",
		"Grants ranged attack capabilities with melee weapons.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.DRAGOON]
	)
	
	# Vampire - Berserker only
	_add_esotera(
		"Vampire",
		"Grants a 25% chance to proc lifesteal on attacks. Amount healed equals 50% of damage dealt per hit.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.BERSERKER]
	)
	
	# Minimalist - Striker, Pugilist, Monk
	_add_esotera(
		"Minimalist",
		"User does not require a weapon equipped to attack.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.STRIKER, Enums.ClassID.PUGILIST, Enums.ClassID.MONK]
	)
	
	# Unseen Fist - Pugilist, Monk
	_add_esotera(
		"Unseen Fist",
		"Grants 10% chance to add one more attack.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.PUGILIST, Enums.ClassID.MONK]
	)
	
	# Gravitas - Phalanx only
	_add_esotera(
		"Gravitas",
		"Enemy units are 30% more likely to target this unit for attacks over others.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.PHALANX]
	)
	
	# Quickdraw - Assassin, Shinobi
	_add_esotera(
		"Quickdraw",
		"Always strikes first (if able) when targeted by an enemy.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.ASSASSIN, Enums.ClassID.SHINOBI]
	)
	
	# Aegis - Vanguard, Hero, Bastion, Phalanx, Paladin
	_add_esotera(
		"Aegis",
		"Allows unit to wield a shield simulatneously with their equipped weapon.",
		EsoteraType.PASSIVE,
		EsoteraSource.INNATE,
		[Enums.ClassID.VANGUARD, Enums.ClassID.HERO, Enums.ClassID.BASTION, Enums.ClassID.PHALANX, Enums.ClassID.PALADIN]
	)
	
	# Discovered Esotera (learnable by any class via Esotera Scroll)
	
	# Mirror
	_add_esotera(
		"Mirror",
		"Upon taking damage, user has a 25% chance of reflecting 50% of the damage taken back at the attacker.",
		EsoteraType.PASSIVE,
		EsoteraSource.DISCOVERED,
		[]
	)
	
	# Last Stand
	_add_esotera(
		"Last Stand",
		"Allows user to survive at 1 HP from a hit that would have killed them. Usable once per floor.",
		EsoteraType.PASSIVE,
		EsoteraSource.DISCOVERED,
		[]
	)
	
	# Phantom
	_add_esotera(
		"Phantom",
		"Allows user to move through enemy units as if they were friendly.",
		EsoteraType.PASSIVE,
		EsoteraSource.DISCOVERED,
		[]
	)

static func _add_esotera(
	name: String,
	description: String,
	type: EsoteraType,
	source: EsoteraSource,
	innate_classes: Array
) -> void:
	esotera[name] = {
		"name": name,
		"description": description,
		"type": type,
		"source": source,
		"innate_classes": innate_classes,
		"effect_function": "" # Placeholder for effect implementation
	}

static func get_esotera(name: String) -> Dictionary:
	return esotera.get(name, {})

static func is_active(name: String) -> bool:
	var data: Dictionary = get_esotera(name)
	return data.get("type", EsoteraType.PASSIVE) == EsoteraType.ACTIVE

static func is_passive(name: String) -> bool:
	return not is_active(name)

static func is_innate(name: String) -> bool:
	var data: Dictionary = get_esotera(name)
	return data.get("source", EsoteraSource.DISCOVERED) == EsoteraSource.INNATE

static func is_discovered(name: String) -> bool:
	return not is_innate(name)

static func can_class_have_esotera(class_id: Enums.ClassID, esotera_name: String) -> bool:
	var data: Dictionary = get_esotera(esotera_name)
	if data.is_empty():
		return false
	
	# If it's discovered, any class can learn it
	if data.get("source") == EsoteraSource.DISCOVERED:
		return true
	
	# If it's innate, check if the class is in the list
	var innate_classes: Array = data.get("innate_classes", [])
	return class_id in innate_classes

static func get_innate_esotera_for_class(class_id: Enums.ClassID) -> Array[String]:
	var result: Array[String] = []
	for esotera_name in esotera.keys():
		var data: Dictionary = esotera[esotera_name]
		if data.get("source") == EsoteraSource.INNATE:
			var innate_classes: Array = data.get("innate_classes", [])
			if class_id in innate_classes:
				result.append(esotera_name)
	return result

static func get_all_esotera_names() -> Array[String]:
	var names: Array[String] = []
	for name in esotera.keys():
		names.append(name)
	return names

static func apply_esotera_effect(esotera_name: String, unit: Unit) -> void:
	# This will be implemented when effect logic is added
	match esotera_name:
		"War Cry":
			_effect_war_cry(unit)
		"Smokescreen":
			_effect_smokescreen(unit)
		"Splitshot":
			_effect_splitshot(unit)
		"Summon":
			_effect_summon(unit)
		"Salvation":
			_effect_salvation(unit)
		"Riposte":
			_effect_riposte(unit)
		"Ambidextrous":
			_effect_ambidextrous(unit)
		"Eclipse":
			_effect_eclipse(unit)
		"Vampire":
			_effect_vampire(unit)
		"Minimalist":
			_effect_minimalist(unit)
		"Unseen Fist":
			_effect_unseen_fist(unit)
		"Gravitas":
			_effect_gravitas(unit)
		"Quickdraw":
			_effect_quickdraw(unit)
		"Aegis":
			_effect_aegis(unit)
		"Mirror":
			_effect_mirror(unit)
		"Last Stand":
			_effect_last_stand(unit)
		"Phantom":
			_effect_phantom(unit)

# Effect implementation stubs - to be filled in later
static func _effect_war_cry(unit: Unit) -> void:
	pass # TODO: Implement War Cry effect

static func _effect_smokescreen(unit: Unit) -> void:
	pass # TODO: Implement Smokescreen effect

static func _effect_splitshot(unit: Unit) -> void:
	pass # TODO: Implement Splitshot effect

static func _effect_summon(unit: Unit) -> void:
	pass # TODO: Implement Summon effect

static func _effect_salvation(unit: Unit) -> void:
	pass # TODO: Implement Salvation effect

static func _effect_riposte(unit: Unit) -> void:
	pass # TODO: Implement Riposte effect

static func _effect_ambidextrous(unit: Unit) -> void:
	# Allows dual wielding
	unit.data.can_dual_wield = true

static func _effect_eclipse(unit: Unit) -> void:
	pass # TODO: Implement Eclipse effect

static func _effect_vampire(unit: Unit) -> void:
	pass # TODO: Implement Vampire effect

static func _effect_minimalist(unit: Unit) -> void:
	pass # TODO: Implement Minimalist effect

static func _effect_unseen_fist(unit: Unit) -> void:
	pass # TODO: Implement Unseen Fist effect

static func _effect_gravitas(unit: Unit) -> void:
	pass # TODO: Implement Gravitas effect

static func _effect_quickdraw(unit: Unit) -> void:
	pass # TODO: Implement Quickdraw effect

static func _effect_aegis(unit: Unit) -> void:
	pass # TODO: Implement Aegis effect

static func _effect_mirror(unit: Unit) -> void:
	pass # TODO: Implement Mirror effect

static func _effect_last_stand(unit: Unit) -> void:
	pass # TODO: Implement Last Stand effect

static func _effect_phantom(unit: Unit) -> void:
	pass # TODO: Implement Phantom effect
