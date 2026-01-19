class_name Enums
## Central repository for all game enumerations.

enum UnitType { PLAYER, ENEMY }

enum Phase { PLAYER_PHASE, ENEMY_PHASE }

enum TileState { EMPTY, PLAYER_UNIT, ENEMY_UNIT, OBSTACLE }

enum Element { NONE, FIRE, WATER, WIND, EARTH, LIGHTNING, HOLY, DARK }

enum ClassID {
	# Captain Line
	CAPTAIN,
	VANGUARD,
	HERO,
	
	# Duelist Line
	DUELIST,
	SWORDMASTER,
	KENSEI,
	
	# Lancer Line
	LANCER,
	SENTINEL,
	DRAGOON,
	
	# Warrior Line
	WARRIOR,
	RAIDER,
	BERSERKER,
	
	# Archer Line
	ARCHER,
	SNIPER,
	HUNTER,
	
	# Guardian Line
	GUARDIAN,
	BASTION,
	PHALANX,
	
	# Rogue Line
	ROGUE,
	ASSASSIN,
	SHINOBI,
	
	# Mage Line
	MAGE,
	SAGE,
	SUMMONER,
	
	# Cleric Line
	CLERIC,
	BISHOP,
	PALADIN,
	
	# Striker Line
	STRIKER,
	PUGILIST,
	MONK
}

enum Tier { BASE, ASCENSION, MASTERY }

enum WeaponType {
	DAGGER,
	LIGHT_SWORD,
	KATANA,
	GREATSWORD,
	LIGHT_AXE,
	GREATAXE,
	SPEAR,
	RANGED_BLADE,
	SCYTHE,
	MACE,
	SHORTBOW,
	LONGBOW,
	GREATBOW,
	FIST,
	BOWSTAFF,
	WAND,
	STAFF,
	TOME,
	SHIELD
}

enum AttackRange { RANGE_0, RANGE_1, RANGE_1_2, RANGE_2 }

enum StatusEffect {
	NONE, BLEED, BLIND, BREAK, BURN, CURSE, DECAY, DRAIN, FREEZE, HEX, HOLLOW, POISON, SHOCK,
	SILENCE, SLOW, VOID
}

enum UnitState { IDLE, EXHAUSTED }
