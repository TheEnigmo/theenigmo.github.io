class_name ClassDatabase
extends Node
## Central database for all class definitions and progression chains.

static var classes: Dictionary = {}

static func initialize() -> void:
	# Captain Line: Captain → Vanguard → Hero
	_add_class(Enums.ClassID.CAPTAIN, "Captain", Enums.Tier.BASE, Enums.ClassID.VANGUARD, [Enums.WeaponType.LIGHT_SWORD])
	_add_class(Enums.ClassID.VANGUARD, "Vanguard", Enums.Tier.ASCENSION, Enums.ClassID.HERO, [Enums.WeaponType.LIGHT_SWORD, Enums.WeaponType.SHIELD])
	_add_class(Enums.ClassID.HERO, "Hero", Enums.Tier.MASTERY, null, [Enums.WeaponType.LIGHT_SWORD, Enums.WeaponType.SHIELD, Enums.WeaponType.GREATSWORD])
	
	# Duelist Line: Duelist → Swordmaster → Kensei
	_add_class(Enums.ClassID.DUELIST, "Duelist", Enums.Tier.BASE, Enums.ClassID.SWORDMASTER, [Enums.WeaponType.LIGHT_SWORD])
	_add_class(Enums.ClassID.SWORDMASTER, "Swordmaster", Enums.Tier.ASCENSION, Enums.ClassID.KENSEI, [Enums.WeaponType.LIGHT_SWORD, Enums.WeaponType.KATANA])
	_add_class(Enums.ClassID.KENSEI, "Kensei", Enums.Tier.MASTERY, null, [Enums.WeaponType.LIGHT_SWORD, Enums.WeaponType.KATANA, Enums.WeaponType.GREATSWORD])
	
	# Lancer Line: Lancer → Sentinel → Dragoon
	_add_class(Enums.ClassID.LANCER, "Lancer", Enums.Tier.BASE, Enums.ClassID.SENTINEL, [Enums.WeaponType.SPEAR])
	_add_class(Enums.ClassID.SENTINEL, "Sentinel", Enums.Tier.ASCENSION, Enums.ClassID.DRAGOON, [Enums.WeaponType.SPEAR, Enums.WeaponType.SCYTHE])
	_add_class(Enums.ClassID.DRAGOON, "Dragoon", Enums.Tier.MASTERY, null, [Enums.WeaponType.SPEAR, Enums.WeaponType.SCYTHE])
	
	# Warrior Line: Warrior → Raider → Berserker
	_add_class(Enums.ClassID.WARRIOR, "Warrior", Enums.Tier.BASE, Enums.ClassID.RAIDER, [Enums.WeaponType.LIGHT_AXE])
	_add_class(Enums.ClassID.RAIDER, "Raider", Enums.Tier.ASCENSION, Enums.ClassID.BERSERKER, [Enums.WeaponType.LIGHT_AXE, Enums.WeaponType.GREATAXE])
	_add_class(Enums.ClassID.BERSERKER, "Berserker", Enums.Tier.MASTERY, null, [Enums.WeaponType.LIGHT_AXE, Enums.WeaponType.GREATAXE])
	
	# Archer Line: Archer → Sniper → Hunter
	_add_class(Enums.ClassID.ARCHER, "Archer", Enums.Tier.BASE, Enums.ClassID.SNIPER, [Enums.WeaponType.SHORTBOW])
	_add_class(Enums.ClassID.SNIPER, "Sniper", Enums.Tier.ASCENSION, Enums.ClassID.HUNTER, [Enums.WeaponType.SHORTBOW, Enums.WeaponType.LONGBOW, Enums.WeaponType.GREATBOW])
	_add_class(Enums.ClassID.HUNTER, "Hunter", Enums.Tier.MASTERY, null, [Enums.WeaponType.SHORTBOW, Enums.WeaponType.LONGBOW, Enums.WeaponType.GREATBOW, Enums.WeaponType.DAGGER])
	
	# Guardian Line: Guardian → Bastion → Phalanx
	_add_class(Enums.ClassID.GUARDIAN, "Guardian", Enums.Tier.BASE, Enums.ClassID.BASTION, [Enums.WeaponType.SPEAR])
	_add_class(Enums.ClassID.BASTION, "Bastion", Enums.Tier.ASCENSION, Enums.ClassID.PHALANX, [Enums.WeaponType.SPEAR, Enums.WeaponType.SHIELD])
	_add_class(Enums.ClassID.PHALANX, "Phalanx", Enums.Tier.MASTERY, null, [Enums.WeaponType.SPEAR, Enums.WeaponType.SHIELD, Enums.WeaponType.MACE])
	
	# Rogue Line: Rogue → Assassin → Shinobi
	_add_class(Enums.ClassID.ROGUE, "Rogue", Enums.Tier.BASE, Enums.ClassID.ASSASSIN, [Enums.WeaponType.DAGGER, Enums.WeaponType.RANGED_BLADE])
	_add_class(Enums.ClassID.ASSASSIN, "Assassin", Enums.Tier.ASCENSION, Enums.ClassID.SHINOBI, [Enums.WeaponType.DAGGER, Enums.WeaponType.RANGED_BLADE])
	_add_class(Enums.ClassID.SHINOBI, "Shinobi", Enums.Tier.MASTERY, null, [Enums.WeaponType.DAGGER, Enums.WeaponType.RANGED_BLADE, Enums.WeaponType.KATANA])
	
	# Mage Line: Mage → Sage → Summoner
	_add_class(Enums.ClassID.MAGE, "Mage", Enums.Tier.BASE, Enums.ClassID.SAGE, [Enums.WeaponType.WAND, Enums.WeaponType.STAFF])
	_add_class(Enums.ClassID.SAGE, "Sage", Enums.Tier.ASCENSION, Enums.ClassID.SUMMONER, [Enums.WeaponType.WAND, Enums.WeaponType.STAFF, Enums.WeaponType.TOME])
	_add_class(Enums.ClassID.SUMMONER, "Summoner", Enums.Tier.MASTERY, null, [Enums.WeaponType.WAND, Enums.WeaponType.STAFF, Enums.WeaponType.TOME])
	
	# Cleric Line: Cleric → Bishop → Paladin
	_add_class(Enums.ClassID.CLERIC, "Cleric", Enums.Tier.BASE, Enums.ClassID.BISHOP, [])
	_add_class(Enums.ClassID.BISHOP, "Bishop", Enums.Tier.ASCENSION, Enums.ClassID.PALADIN, [Enums.WeaponType.STAFF])
	_add_class(Enums.ClassID.PALADIN, "Paladin", Enums.Tier.MASTERY, null, [Enums.WeaponType.STAFF, Enums.WeaponType.MACE, Enums.WeaponType.SHIELD])
	
	# Striker Line: Striker → Pugilist → Monk
	_add_class(Enums.ClassID.STRIKER, "Striker", Enums.Tier.BASE, Enums.ClassID.PUGILIST, [Enums.WeaponType.FIST])
	_add_class(Enums.ClassID.PUGILIST, "Pugilist", Enums.Tier.ASCENSION, Enums.ClassID.MONK, [Enums.WeaponType.FIST])
	_add_class(Enums.ClassID.MONK, "Monk", Enums.Tier.MASTERY, null, [Enums.WeaponType.FIST, Enums.WeaponType.BOWSTAFF])

static func _add_class(id: Enums.ClassID, name: String, tier: Enums.Tier, promotes_to, proficiencies: Array[Enums.WeaponType]) -> void:
	classes[id] = {
		"name": name,
		"tier": tier,
		"promotes_to": promotes_to,
		"proficiencies": proficiencies
	}

static func get_class_name(id: Enums.ClassID) -> String:
	return classes.get(id, {}).get("name", "Unknown")

static func get_class_tier(id: Enums.ClassID) -> Enums.Tier:
	return classes.get(id, {}).get("tier", Enums.Tier.BASE)

static func get_promotion_target(id: Enums.ClassID):
	return classes.get(id, {}).get("promotes_to", null)

static func can_promote(id: Enums.ClassID) -> bool:
	return get_promotion_target(id) != null

static func can_use_weapon(class_id: Enums.ClassID, weapon_type: Enums.WeaponType) -> bool:
	var proficiencies: Array = classes.get(class_id, {}).get("proficiencies", [])
	return weapon_type in proficiencies
