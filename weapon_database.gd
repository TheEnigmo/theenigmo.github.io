extends Node

static var weapons: Dictionary = {}

static func initialize() -> void:
	# Training weapons - all have no special effects
	_create_weapon("Training Dagger", Enums.WeaponType.DAGGER, Enums.AttackRange.RANGE_1, 0, 0.25, 0, 0.15, 0, 0, 0)
	_create_weapon("Training Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0)
	_create_weapon("Training Katana", Enums.WeaponType.KATANA, Enums.AttackRange.RANGE_1, 0, 0.50, 0, 0, 0, 0, 0.25)
	_create_weapon("Training Greatsword", Enums.WeaponType.GREATSWORD, Enums.AttackRange.RANGE_1, 0, 0.60, 0.15, -0.40, 0, 0, 0)
	_create_weapon("Training Axe", Enums.WeaponType.LIGHT_AXE, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0)
	_create_weapon("Training Greataxe", Enums.WeaponType.GREATAXE, Enums.AttackRange.RANGE_1, 0, 0.70, 0.15, -0.50, 0, 0, 0)
	_create_weapon("Training Spear", Enums.WeaponType.SPEAR, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0)
	_create_weapon("Training Shuriken", Enums.WeaponType.RANGED_BLADE, Enums.AttackRange.RANGE_2, 0, 0.15, 0, 0.30, 0, 0, 0)
	_create_weapon("Training Scythe", Enums.WeaponType.SCYTHE, Enums.AttackRange.RANGE_1, 0, 0.50, 0, 0, 0, 0, 0.25)
	_create_weapon("Training Mace", Enums.WeaponType.MACE, Enums.AttackRange.RANGE_1, 0, 0.30, 0, 0, 0, 0.15, 0)
	_create_weapon("Training Shortbow", Enums.WeaponType.SHORTBOW, Enums.AttackRange.RANGE_2, 0, 0.25, 0, 0.15, 0, 0, 0)
	_create_weapon("Training Longbow", Enums.WeaponType.LONGBOW, Enums.AttackRange.RANGE_2, 0, 0.40, 0, 0, 0, 0, 0)
	_create_weapon("Training Greatbow", Enums.WeaponType.GREATBOW, Enums.AttackRange.RANGE_2, 0, 0.60, 0, -0.30, 0, 0, 0)
	_create_weapon("Training Handwraps", Enums.WeaponType.FIST, Enums.AttackRange.RANGE_1, 0, 0.25, 0, 0.25, 0, 0, 0)
	_create_weapon("Training Gauntlet", Enums.WeaponType.FIST, Enums.AttackRange.RANGE_1, 0, 0.50, 0.15, -0.30, 0, 0, 0)
	_create_weapon("Training Bowstaff", Enums.WeaponType.BOWSTAFF, Enums.AttackRange.RANGE_1, 0, 0.30, 0, 0, 0, 0.25, 0)
	_create_weapon("Training Wand", Enums.WeaponType.WAND, Enums.AttackRange.RANGE_1_2, 0, 0, 0, 0.08, 0.25, 0, 0)
	_create_weapon("Training Staff", Enums.WeaponType.STAFF, Enums.AttackRange.RANGE_1_2, 0, 0, 0, 0, 0.40, 0, 0)
	_create_weapon("Training Tome", Enums.WeaponType.TOME, Enums.AttackRange.RANGE_1_2, 0, 0, 0, -0.15, 0.50, 0, 0)
	_create_weapon("Training Shield", Enums.WeaponType.SHIELD, Enums.AttackRange.RANGE_0, 0, 0, 0.50, 0, 0, 0.15, 0)
	
	# Test Status Effect Swords - All have 100% (1.0) chance to inflict
	_create_weapon("Test Bleed Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.BLEED, 1.0, 3)
	_create_weapon("Test Blind Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.BLIND, 1.0, 2)
	_create_weapon("Test Break Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.BREAK, 1.0, 3)
	_create_weapon("Test Burn Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.BURN, 1.0, 3)
	_create_weapon("Test Curse Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.CURSE, 1.0, 2)
	_create_weapon("Test Decay Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.DECAY, 1.0, 3)
	_create_weapon("Test Drain Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.DRAIN, 1.0, 2)
	_create_weapon("Test Freeze Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.FREEZE, 1.0, 2)
	_create_weapon("Test Hex Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.HEX, 1.0, 2)
	_create_weapon("Test Hollow Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.HOLLOW, 1.0, 2)
	_create_weapon("Test Poison Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.POISON, 1.0, 3)
	_create_weapon("Test Shock Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.SHOCK, 1.0, 2)
	_create_weapon("Test Silence Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.SILENCE, 1.0, 2)
	_create_weapon("Test Slow Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.SLOW, 1.0, 2)
	_create_weapon("Test Void Sword", Enums.WeaponType.LIGHT_SWORD, Enums.AttackRange.RANGE_1, 0, 0.40, 0, 0, 0, 0, 0, Enums.StatusEffect.VOID, 1.0, 2)

static func _create_weapon(name: String, type: Enums.WeaponType, range: Enums.AttackRange, 
							hp: float, atk: float, def: float, spd: float, int_val: float, res: float, luk: float,
							status_effect: Enums.StatusEffect = Enums.StatusEffect.NONE, 
							effect_chance: float = 1.0, 
							effect_duration: int = 0) -> void:
	var weapon := WeaponData.new()
	weapon.weapon_name = name
	weapon.weapon_type = type
	weapon.attack_range = range
	weapon.hp_mod = hp
	weapon.atk_mod = atk
	weapon.def_mod = def
	weapon.spd_mod = spd
	weapon.int_mod = int_val
	weapon.res_mod = res
	weapon.luk_mod = luk
	weapon.applies_status_effect = status_effect
	weapon.status_effect_chance = effect_chance
	weapon.status_effect_duration = effect_duration
	weapons[name] = weapon

static func get_weapon(name: String) -> WeaponData:
	return weapons.get(name)
