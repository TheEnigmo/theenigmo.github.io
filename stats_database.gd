class_name StatsDatabase
extends Node
## Pre-calculated stat lookup tables for all classes across all levels.
## Growth is evenly distributed between Lv1 and Lv10/20.

static var class_stats: Dictionary = {}

static func initialize() -> void:
	# CAPTAIN TREE
	_add_class_stats(Enums.ClassID.CAPTAIN, Enums.Tier.BASE, 10, [
		{"hp": 24, "atk": 15, "def": 12, "spd": 14, "int": 10, "res": 11, "luk": 14},
		{"hp": 25, "atk": 16, "def": 13, "spd": 15, "int": 11, "res": 11, "luk": 14},
		{"hp": 27, "atk": 17, "def": 14, "spd": 16, "int": 12, "res": 12, "luk": 15},
		{"hp": 28, "atk": 18, "def": 15, "spd": 17, "int": 13, "res": 13, "luk": 15},
		{"hp": 30, "atk": 19, "def": 16, "spd": 17, "int": 14, "res": 14, "luk": 16},
		{"hp": 31, "atk": 20, "def": 17, "spd": 18, "int": 15, "res": 15, "luk": 16},
		{"hp": 33, "atk": 21, "def": 18, "spd": 19, "int": 16, "res": 16, "luk": 17},
		{"hp": 34, "atk": 23, "def": 19, "spd": 20, "int": 17, "res": 17, "luk": 17},
		{"hp": 35, "atk": 24, "def": 20, "spd": 20, "int": 18, "res": 17, "luk": 18},
		{"hp": 36, "atk": 25, "def": 21, "spd": 21, "int": 20, "res": 18, "luk": 19}
	])
	
	_add_class_stats(Enums.ClassID.VANGUARD, Enums.Tier.ASCENSION, 10, [
		{"hp": 41, "atk": 33, "def": 31, "spd": 21, "int": 20, "res": 20, "luk": 19},
		{"hp": 42, "atk": 33, "def": 32, "spd": 21, "int": 20, "res": 20, "luk": 19},
		{"hp": 43, "atk": 34, "def": 33, "spd": 22, "int": 21, "res": 21, "luk": 20},
		{"hp": 44, "atk": 35, "def": 34, "spd": 22, "int": 21, "res": 21, "luk": 20},
		{"hp": 45, "atk": 36, "def": 35, "spd": 23, "int": 22, "res": 22, "luk": 20},
		{"hp": 46, "atk": 37, "def": 36, "spd": 24, "int": 23, "res": 22, "luk": 21},
		{"hp": 47, "atk": 38, "def": 37, "spd": 24, "int": 23, "res": 23, "luk": 21},
		{"hp": 48, "atk": 39, "def": 38, "spd": 25, "int": 24, "res": 23, "luk": 21},
		{"hp": 48, "atk": 39, "def": 38, "spd": 25, "int": 24, "res": 23, "luk": 22},
		{"hp": 49, "atk": 40, "def": 39, "spd": 26, "int": 25, "res": 24, "luk": 22}
	])
	
	_add_class_stats(Enums.ClassID.HERO, Enums.Tier.MASTERY, 20, [
		{"hp": 52, "atk": 50, "def": 42, "spd": 31, "int": 27, "res": 24, "luk": 29},
		{"hp": 53, "atk": 52, "def": 43, "spd": 32, "int": 27, "res": 24, "luk": 30},
		{"hp": 54, "atk": 54, "def": 44, "spd": 33, "int": 28, "res": 25, "luk": 31},
		{"hp": 55, "atk": 56, "def": 45, "spd": 34, "int": 28, "res": 26, "luk": 31},
		{"hp": 56, "atk": 58, "def": 46, "spd": 35, "int": 29, "res": 26, "luk": 32},
		{"hp": 58, "atk": 60, "def": 46, "spd": 36, "int": 30, "res": 27, "luk": 33},
		{"hp": 59, "atk": 62, "def": 47, "spd": 37, "int": 30, "res": 28, "luk": 34},
		{"hp": 60, "atk": 64, "def": 48, "spd": 38, "int": 31, "res": 28, "luk": 35},
		{"hp": 61, "atk": 66, "def": 49, "spd": 40, "int": 32, "res": 29, "luk": 36},
		{"hp": 62, "atk": 67, "def": 50, "spd": 41, "int": 32, "res": 30, "luk": 37},
		{"hp": 63, "atk": 67, "def": 50, "spd": 42, "int": 33, "res": 30, "luk": 37},
		{"hp": 63, "atk": 67, "def": 50, "spd": 42, "int": 33, "res": 30, "luk": 37},
		{"hp": 63, "atk": 67, "def": 51, "spd": 42, "int": 33, "res": 30, "luk": 38},
		{"hp": 63, "atk": 67, "def": 51, "spd": 43, "int": 33, "res": 31, "luk": 38},
		{"hp": 63, "atk": 68, "def": 51, "spd": 43, "int": 34, "res": 31, "luk": 38},
		{"hp": 64, "atk": 68, "def": 51, "spd": 44, "int": 34, "res": 31, "luk": 38},
		{"hp": 64, "atk": 68, "def": 51, "spd": 44, "int": 34, "res": 31, "luk": 39},
		{"hp": 64, "atk": 68, "def": 52, "spd": 44, "int": 35, "res": 32, "luk": 39},
		{"hp": 64, "atk": 68, "def": 52, "spd": 44, "int": 35, "res": 32, "luk": 39},
		{"hp": 64, "atk": 68, "def": 52, "spd": 45, "int": 35, "res": 32, "luk": 39}
	])
	
	# DUELIST TREE
	_add_class_stats(Enums.ClassID.DUELIST, Enums.Tier.BASE, 10, [
		{"hp": 22, "atk": 16, "def": 10, "spd": 18, "int": 6, "res": 10, "luk": 18},
		{"hp": 23, "atk": 17, "def": 10, "spd": 20, "int": 6, "res": 10, "luk": 20},
		{"hp": 24, "atk": 18, "def": 11, "spd": 21, "int": 6, "res": 11, "luk": 21},
		{"hp": 25, "atk": 19, "def": 12, "spd": 23, "int": 7, "res": 11, "luk": 23},
		{"hp": 26, "atk": 20, "def": 12, "spd": 25, "int": 7, "res": 12, "luk": 25},
		{"hp": 27, "atk": 21, "def": 13, "spd": 26, "int": 7, "res": 12, "luk": 26},
		{"hp": 28, "atk": 23, "def": 14, "spd": 28, "int": 8, "res": 13, "luk": 28},
		{"hp": 29, "atk": 24, "def": 15, "spd": 30, "int": 8, "res": 14, "luk": 30},
		{"hp": 29, "atk": 25, "def": 15, "spd": 31, "int": 8, "res": 14, "luk": 31},
		{"hp": 30, "atk": 26, "def": 16, "spd": 32, "int": 9, "res": 15, "luk": 32}
	])
	
	_add_class_stats(Enums.ClassID.SWORDMASTER, Enums.Tier.ASCENSION, 10, [
		{"hp": 32, "atk": 29, "def": 18, "spd": 41, "int": 9, "res": 17, "luk": 39},
		{"hp": 32, "atk": 29, "def": 18, "spd": 42, "int": 9, "res": 17, "luk": 40},
		{"hp": 33, "atk": 30, "def": 19, "spd": 43, "int": 9, "res": 18, "luk": 41},
		{"hp": 34, "atk": 31, "def": 19, "spd": 44, "int": 9, "res": 18, "luk": 42},
		{"hp": 35, "atk": 32, "def": 20, "spd": 45, "int": 10, "res": 19, "luk": 43},
		{"hp": 36, "atk": 33, "def": 21, "spd": 46, "int": 10, "res": 19, "luk": 44},
		{"hp": 36, "atk": 34, "def": 21, "spd": 47, "int": 10, "res": 20, "luk": 45},
		{"hp": 37, "atk": 35, "def": 22, "spd": 48, "int": 10, "res": 20, "luk": 46},
		{"hp": 37, "atk": 35, "def": 22, "spd": 48, "int": 11, "res": 20, "luk": 46},
		{"hp": 38, "atk": 36, "def": 23, "spd": 49, "int": 11, "res": 21, "luk": 47}
	])
	
	_add_class_stats(Enums.ClassID.KENSEI, Enums.Tier.MASTERY, 20, [
		{"hp": 41, "atk": 46, "def": 26, "spd": 54, "int": 11, "res": 23, "luk": 54},
		{"hp": 42, "atk": 48, "def": 27, "spd": 55, "int": 11, "res": 23, "luk": 56},
		{"hp": 43, "atk": 50, "def": 28, "spd": 56, "int": 11, "res": 24, "luk": 58},
		{"hp": 44, "atk": 52, "def": 29, "spd": 58, "int": 11, "res": 24, "luk": 60},
		{"hp": 45, "atk": 54, "def": 30, "spd": 59, "int": 12, "res": 25, "luk": 62},
		{"hp": 46, "atk": 56, "def": 31, "spd": 61, "int": 12, "res": 26, "luk": 64},
		{"hp": 47, "atk": 58, "def": 31, "spd": 62, "int": 12, "res": 26, "luk": 66},
		{"hp": 48, "atk": 60, "def": 32, "spd": 63, "int": 12, "res": 27, "luk": 68},
		{"hp": 49, "atk": 62, "def": 33, "spd": 65, "int": 13, "res": 28, "luk": 70},
		{"hp": 50, "atk": 63, "def": 34, "spd": 66, "int": 13, "res": 28, "luk": 71},
		{"hp": 51, "atk": 63, "def": 34, "spd": 66, "int": 13, "res": 28, "luk": 72},
		{"hp": 51, "atk": 64, "def": 34, "spd": 66, "int": 13, "res": 29, "luk": 72},
		{"hp": 52, "atk": 64, "def": 34, "spd": 67, "int": 13, "res": 29, "luk": 72},
		{"hp": 52, "atk": 64, "def": 34, "spd": 67, "int": 13, "res": 29, "luk": 72},
		{"hp": 52, "atk": 64, "def": 35, "spd": 67, "int": 13, "res": 29, "luk": 72},
		{"hp": 52, "atk": 64, "def": 35, "spd": 67, "int": 14, "res": 29, "luk": 72},
		{"hp": 53, "atk": 64, "def": 35, "spd": 67, "int": 14, "res": 30, "luk": 72},
		{"hp": 53, "atk": 64, "def": 35, "spd": 67, "int": 14, "res": 30, "luk": 72},
		{"hp": 53, "atk": 64, "def": 35, "spd": 67, "int": 14, "res": 30, "luk": 72},
		{"hp": 53, "atk": 64, "def": 35, "spd": 67, "int": 14, "res": 30, "luk": 72}
	])
	
	# LANCER TREE
	_add_class_stats(Enums.ClassID.LANCER, Enums.Tier.BASE, 10, [
		{"hp": 24, "atk": 16, "def": 13, "spd": 17, "int": 6, "res": 11, "luk": 13},
		{"hp": 25, "atk": 17, "def": 14, "spd": 18, "int": 6, "res": 11, "luk": 14},
		{"hp": 27, "atk": 18, "def": 15, "spd": 19, "int": 6, "res": 12, "luk": 15},
		{"hp": 28, "atk": 19, "def": 16, "spd": 21, "int": 7, "res": 13, "luk": 16},
		{"hp": 30, "atk": 20, "def": 17, "spd": 22, "int": 7, "res": 14, "luk": 18},
		{"hp": 31, "atk": 21, "def": 18, "spd": 23, "int": 7, "res": 14, "luk": 19},
		{"hp": 33, "atk": 23, "def": 19, "spd": 25, "int": 8, "res": 15, "luk": 20},
		{"hp": 34, "atk": 24, "def": 20, "spd": 26, "int": 8, "res": 16, "luk": 21},
		{"hp": 35, "atk": 25, "def": 20, "spd": 27, "int": 8, "res": 16, "luk": 22},
		{"hp": 36, "atk": 26, "def": 21, "spd": 28, "int": 9, "res": 17, "luk": 23}
	])
	
	_add_class_stats(Enums.ClassID.SENTINEL, Enums.Tier.ASCENSION, 10, [
		{"hp": 40, "atk": 29, "def": 24, "spd": 36, "int": 9, "res": 19, "luk": 28},
		{"hp": 41, "atk": 29, "def": 24, "spd": 36, "int": 9, "res": 19, "luk": 28},
		{"hp": 42, "atk": 30, "def": 25, "spd": 37, "int": 9, "res": 19, "luk": 29},
		{"hp": 43, "atk": 31, "def": 26, "spd": 38, "int": 9, "res": 20, "luk": 30},
		{"hp": 44, "atk": 32, "def": 27, "spd": 39, "int": 10, "res": 20, "luk": 31},
		{"hp": 45, "atk": 33, "def": 28, "spd": 40, "int": 10, "res": 21, "luk": 31},
		{"hp": 46, "atk": 34, "def": 28, "spd": 41, "int": 10, "res": 21, "luk": 32},
		{"hp": 47, "atk": 35, "def": 29, "spd": 42, "int": 10, "res": 22, "luk": 33},
		{"hp": 47, "atk": 35, "def": 29, "spd": 42, "int": 11, "res": 22, "luk": 33},
		{"hp": 48, "atk": 36, "def": 30, "spd": 43, "int": 11, "res": 23, "luk": 34}
	])
	
	_add_class_stats(Enums.ClassID.DRAGOON, Enums.Tier.MASTERY, 20, [
		{"hp": 52, "atk": 42, "def": 33, "spd": 48, "int": 11, "res": 25, "luk": 44},
		{"hp": 53, "atk": 44, "def": 34, "spd": 49, "int": 11, "res": 25, "luk": 46},
		{"hp": 54, "atk": 46, "def": 35, "spd": 50, "int": 11, "res": 26, "luk": 48},
		{"hp": 55, "atk": 48, "def": 36, "spd": 51, "int": 11, "res": 26, "luk": 50},
		{"hp": 56, "atk": 50, "def": 37, "spd": 53, "int": 12, "res": 27, "luk": 52},
		{"hp": 58, "atk": 52, "def": 38, "spd": 54, "int": 12, "res": 28, "luk": 54},
		{"hp": 59, "atk": 54, "def": 38, "spd": 55, "int": 12, "res": 28, "luk": 56},
		{"hp": 60, "atk": 56, "def": 39, "spd": 56, "int": 12, "res": 29, "luk": 58},
		{"hp": 61, "atk": 58, "def": 40, "spd": 58, "int": 13, "res": 30, "luk": 60},
		{"hp": 62, "atk": 59, "def": 40, "spd": 59, "int": 13, "res": 30, "luk": 62},
		{"hp": 63, "atk": 60, "def": 41, "spd": 60, "int": 13, "res": 30, "luk": 63},
		{"hp": 63, "atk": 60, "def": 41, "spd": 60, "int": 13, "res": 30, "luk": 63},
		{"hp": 64, "atk": 60, "def": 41, "spd": 60, "int": 13, "res": 31, "luk": 63},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 13, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 13, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 14, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 14, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 14, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 14, "res": 31, "luk": 64},
		{"hp": 64, "atk": 60, "def": 41, "spd": 61, "int": 14, "res": 31, "luk": 64}
	])
	
	# WARRIOR TREE
	_add_class_stats(Enums.ClassID.WARRIOR, Enums.Tier.BASE, 10, [
		{"hp": 30, "atk": 19, "def": 13, "spd": 12, "int": 5, "res": 9, "luk": 12},
		{"hp": 32, "atk": 20, "def": 14, "spd": 12, "int": 5, "res": 9, "luk": 12},
		{"hp": 34, "atk": 21, "def": 15, "spd": 13, "int": 5, "res": 10, "luk": 13},
		{"hp": 36, "atk": 23, "def": 16, "spd": 14, "int": 6, "res": 10, "luk": 14},
		{"hp": 38, "atk": 24, "def": 17, "spd": 15, "int": 6, "res": 11, "luk": 15},
		{"hp": 40, "atk": 25, "def": 18, "spd": 16, "int": 6, "res": 11, "luk": 16},
		{"hp": 42, "atk": 27, "def": 19, "spd": 16, "int": 7, "res": 12, "luk": 17},
		{"hp": 44, "atk": 28, "def": 20, "spd": 17, "int": 7, "res": 13, "luk": 18},
		{"hp": 46, "atk": 29, "def": 20, "spd": 18, "int": 7, "res": 13, "luk": 18},
		{"hp": 48, "atk": 31, "def": 21, "spd": 19, "int": 8, "res": 14, "luk": 19}
	])
	
	_add_class_stats(Enums.ClassID.RAIDER, Enums.Tier.ASCENSION, 10, [
		{"hp": 54, "atk": 40, "def": 24, "spd": 21, "int": 8, "res": 16, "luk": 22},
		{"hp": 55, "atk": 41, "def": 24, "spd": 21, "int": 8, "res": 16, "luk": 22},
		{"hp": 56, "atk": 42, "def": 25, "spd": 22, "int": 8, "res": 17, "luk": 23},
		{"hp": 58, "atk": 43, "def": 26, "spd": 22, "int": 9, "res": 17, "luk": 23},
		{"hp": 59, "atk": 44, "def": 27, "spd": 23, "int": 9, "res": 18, "luk": 24},
		{"hp": 60, "atk": 45, "def": 28, "spd": 24, "int": 9, "res": 18, "luk": 24},
		{"hp": 61, "atk": 46, "def": 28, "spd": 24, "int": 9, "res": 19, "luk": 25},
		{"hp": 62, "atk": 47, "def": 29, "spd": 25, "int": 9, "res": 19, "luk": 25},
		{"hp": 63, "atk": 48, "def": 29, "spd": 25, "int": 10, "res": 19, "luk": 25},
		{"hp": 64, "atk": 49, "def": 30, "spd": 26, "int": 10, "res": 20, "luk": 26}
	])
	
	_add_class_stats(Enums.ClassID.BERSERKER, Enums.Tier.MASTERY, 20, [
		{"hp": 70, "atk": 60, "def": 33, "spd": 28, "int": 10, "res": 22, "luk": 32},
		{"hp": 72, "atk": 62, "def": 34, "spd": 28, "int": 10, "res": 22, "luk": 33},
		{"hp": 74, "atk": 65, "def": 35, "spd": 29, "int": 10, "res": 23, "luk": 35},
		{"hp": 76, "atk": 67, "def": 36, "spd": 30, "int": 11, "res": 23, "luk": 37},
		{"hp": 78, "atk": 69, "def": 37, "spd": 31, "int": 11, "res": 24, "luk": 39},
		{"hp": 80, "atk": 72, "def": 38, "spd": 31, "int": 11, "res": 25, "luk": 41},
		{"hp": 82, "atk": 74, "def": 38, "spd": 32, "int": 12, "res": 25, "luk": 43},
		{"hp": 84, "atk": 76, "def": 39, "spd": 33, "int": 12, "res": 26, "luk": 45},
		{"hp": 86, "atk": 79, "def": 40, "spd": 34, "int": 12, "res": 27, "luk": 46},
		{"hp": 87, "atk": 81, "def": 40, "spd": 34, "int": 12, "res": 27, "luk": 46},
		{"hp": 88, "atk": 82, "def": 41, "spd": 35, "int": 13, "res": 27, "luk": 47},
		{"hp": 88, "atk": 82, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 82, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47},
		{"hp": 88, "atk": 83, "def": 41, "spd": 35, "int": 13, "res": 28, "luk": 47}
	])
	
	# ARCHER TREE
	_add_class_stats(Enums.ClassID.ARCHER, Enums.Tier.BASE, 10, [
		{"hp": 21, "atk": 14, "def": 9, "spd": 19, "int": 7, "res": 12, "luk": 18},
		{"hp": 22, "atk": 15, "def": 9, "spd": 20, "int": 7, "res": 12, "luk": 19},
		{"hp": 23, "atk": 16, "def": 10, "spd": 21, "int": 8, "res": 13, "luk": 20},
		{"hp": 24, "atk": 17, "def": 11, "spd": 23, "int": 8, "res": 14, "luk": 22},
		{"hp": 25, "atk": 18, "def": 11, "spd": 24, "int": 9, "res": 15, "luk": 23},
		{"hp": 26, "atk": 19, "def": 12, "spd": 26, "int": 9, "res": 15, "luk": 25},
		{"hp": 28, "atk": 21, "def": 13, "spd": 27, "int": 10, "res": 16, "luk": 26},
		{"hp": 29, "atk": 22, "def": 14, "spd": 29, "int": 10, "res": 17, "luk": 28},
		{"hp": 30, "atk": 23, "def": 14, "spd": 30, "int": 10, "res": 17, "luk": 29},
		{"hp": 31, "atk": 24, "def": 15, "spd": 31, "int": 11, "res": 18, "luk": 30}
	])
	
	_add_class_stats(Enums.ClassID.SNIPER, Enums.Tier.ASCENSION, 10, [
		{"hp": 34, "atk": 30, "def": 17, "spd": 39, "int": 12, "res": 20, "luk": 33},
		{"hp": 35, "atk": 31, "def": 17, "spd": 40, "int": 12, "res": 20, "luk": 34},
		{"hp": 36, "atk": 32, "def": 18, "spd": 41, "int": 12, "res": 21, "luk": 35},
		{"hp": 37, "atk": 33, "def": 19, "spd": 42, "int": 12, "res": 21, "luk": 35},
		{"hp": 38, "atk": 34, "def": 19, "spd": 43, "int": 13, "res": 22, "luk": 36},
		{"hp": 38, "atk": 35, "def": 20, "spd": 44, "int": 13, "res": 22, "luk": 37},
		{"hp": 39, "atk": 36, "def": 20, "spd": 45, "int": 13, "res": 23, "luk": 37},
		{"hp": 40, "atk": 37, "def": 21, "spd": 46, "int": 13, "res": 23, "luk": 38},
		{"hp": 40, "atk": 37, "def": 21, "spd": 46, "int": 14, "res": 23, "luk": 38},
		{"hp": 41, "atk": 38, "def": 22, "spd": 47, "int": 14, "res": 24, "luk": 39}
	])
	
	_add_class_stats(Enums.ClassID.HUNTER, Enums.Tier.MASTERY, 20, [
		{"hp": 44, "atk": 44, "def": 24, "spd": 52, "int": 15, "res": 26, "luk": 50},
		{"hp": 45, "atk": 46, "def": 24, "spd": 54, "int": 15, "res": 26, "luk": 52},
		{"hp": 46, "atk": 48, "def": 25, "spd": 55, "int": 15, "res": 27, "luk": 55},
		{"hp": 47, "atk": 50, "def": 26, "spd": 57, "int": 15, "res": 27, "luk": 57},
		{"hp": 48, "atk": 52, "def": 27, "spd": 59, "int": 16, "res": 28, "luk": 60},
		{"hp": 49, "atk": 54, "def": 28, "spd": 61, "int": 16, "res": 29, "luk": 62},
		{"hp": 50, "atk": 56, "def": 28, "spd": 62, "int": 16, "res": 29, "luk": 64},
		{"hp": 51, "atk": 58, "def": 29, "spd": 64, "int": 16, "res": 30, "luk": 67},
		{"hp": 52, "atk": 59, "def": 30, "spd": 66, "int": 17, "res": 31, "luk": 69},
		{"hp": 53, "atk": 59, "def": 30, "spd": 67, "int": 17, "res": 31, "luk": 71},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 17, "res": 31, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 17, "res": 31, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 17, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 17, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72},
		{"hp": 54, "atk": 60, "def": 31, "spd": 68, "int": 18, "res": 32, "luk": 72}
	])
	
	# GUARDIAN TREE
	_add_class_stats(Enums.ClassID.GUARDIAN, Enums.Tier.BASE, 10, [
		{"hp": 28, "atk": 16, "def": 20, "spd": 10, "int": 6, "res": 8, "luk": 12},
		{"hp": 30, "atk": 17, "def": 21, "spd": 10, "int": 6, "res": 8, "luk": 12},
		{"hp": 32, "atk": 18, "def": 23, "spd": 11, "int": 6, "res": 9, "luk": 13},
		{"hp": 34, "atk": 19, "def": 25, "spd": 11, "int": 7, "res": 9, "luk": 13},
		{"hp": 36, "atk": 20, "def": 27, "spd": 12, "int": 7, "res": 10, "luk": 14},
		{"hp": 38, "atk": 21, "def": 29, "spd": 12, "int": 7, "res": 10, "luk": 14},
		{"hp": 40, "atk": 23, "def": 30, "spd": 13, "int": 8, "res": 11, "luk": 15},
		{"hp": 42, "atk": 24, "def": 32, "spd": 14, "int": 8, "res": 12, "luk": 16},
		{"hp": 44, "atk": 25, "def": 33, "spd": 14, "int": 8, "res": 12, "luk": 16},
		{"hp": 46, "atk": 26, "def": 34, "spd": 15, "int": 9, "res": 13, "luk": 17}
	])
	
	_add_class_stats(Enums.ClassID.BASTION, Enums.Tier.ASCENSION, 10, [
		{"hp": 54, "atk": 31, "def": 42, "spd": 16, "int": 9, "res": 15, "luk": 18},
		{"hp": 55, "atk": 32, "def": 43, "spd": 16, "int": 9, "res": 15, "luk": 18},
		{"hp": 57, "atk": 33, "def": 44, "spd": 17, "int": 9, "res": 16, "luk": 18},
		{"hp": 59, "atk": 33, "def": 46, "spd": 17, "int": 9, "res": 16, "luk": 18},
		{"hp": 60, "atk": 34, "def": 47, "spd": 18, "int": 10, "res": 17, "luk": 18},
		{"hp": 62, "atk": 35, "def": 48, "spd": 18, "int": 10, "res": 17, "luk": 18},
		{"hp": 63, "atk": 36, "def": 49, "spd": 19, "int": 10, "res": 18, "luk": 19},
		{"hp": 65, "atk": 37, "def": 50, "spd": 19, "int": 10, "res": 18, "luk": 19},
		{"hp": 65, "atk": 37, "def": 51, "spd": 19, "int": 11, "res": 18, "luk": 19},
		{"hp": 66, "atk": 38, "def": 52, "spd": 20, "int": 11, "res": 19, "luk": 19}
	])
	
	_add_class_stats(Enums.ClassID.PHALANX, Enums.Tier.MASTERY, 20, [
		{"hp": 74, "atk": 42, "def": 62, "spd": 21, "int": 11, "res": 21, "luk": 24},
		{"hp": 75, "atk": 43, "def": 64, "spd": 21, "int": 11, "res": 22, "luk": 26},
		{"hp": 77, "atk": 44, "def": 67, "spd": 22, "int": 11, "res": 23, "luk": 28},
		{"hp": 78, "atk": 45, "def": 69, "spd": 22, "int": 11, "res": 23, "luk": 30},
		{"hp": 80, "atk": 46, "def": 71, "spd": 23, "int": 12, "res": 24, "luk": 32},
		{"hp": 81, "atk": 47, "def": 74, "spd": 24, "int": 12, "res": 25, "luk": 34},
		{"hp": 82, "atk": 48, "def": 76, "spd": 24, "int": 12, "res": 26, "luk": 36},
		{"hp": 84, "atk": 49, "def": 78, "spd": 25, "int": 12, "res": 26, "luk": 38},
		{"hp": 85, "atk": 50, "def": 81, "spd": 26, "int": 13, "res": 27, "luk": 40},
		{"hp": 85, "atk": 51, "def": 83, "spd": 26, "int": 13, "res": 28, "luk": 41},
		{"hp": 86, "atk": 51, "def": 84, "spd": 27, "int": 13, "res": 28, "luk": 42},
		{"hp": 86, "atk": 52, "def": 84, "spd": 27, "int": 13, "res": 28, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 13, "res": 28, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42},
		{"hp": 86, "atk": 52, "def": 85, "spd": 27, "int": 14, "res": 29, "luk": 42}
	])
	
	# ROGUE TREE
	_add_class_stats(Enums.ClassID.ROGUE, Enums.Tier.BASE, 10, [
		{"hp": 21, "atk": 14, "def": 8, "spd": 20, "int": 7, "res": 10, "luk": 20},
		{"hp": 22, "atk": 15, "def": 9, "spd": 21, "int": 7, "res": 10, "luk": 21},
		{"hp": 23, "atk": 16, "def": 9, "spd": 23, "int": 8, "res": 11, "luk": 23},
		{"hp": 24, "atk": 17, "def": 10, "spd": 25, "int": 8, "res": 11, "luk": 25},
		{"hp": 25, "atk": 18, "def": 11, "spd": 27, "int": 9, "res": 12, "luk": 27},
		{"hp": 26, "atk": 19, "def": 11, "spd": 28, "int": 9, "res": 12, "luk": 29},
		{"hp": 27, "atk": 21, "def": 12, "spd": 30, "int": 10, "res": 13, "luk": 31},
		{"hp": 28, "atk": 22, "def": 13, "spd": 32, "int": 10, "res": 14, "luk": 32},
		{"hp": 28, "atk": 23, "def": 13, "spd": 32, "int": 10, "res": 14, "luk": 33},
		{"hp": 29, "atk": 24, "def": 14, "spd": 33, "int": 11, "res": 15, "luk": 34}
	])
	
	_add_class_stats(Enums.ClassID.ASSASSIN, Enums.Tier.ASCENSION, 10, [
		{"hp": 31, "atk": 27, "def": 16, "spd": 42, "int": 11, "res": 17, "luk": 41},
		{"hp": 32, "atk": 28, "def": 16, "spd": 43, "int": 11, "res": 17, "luk": 42},
		{"hp": 33, "atk": 29, "def": 17, "spd": 44, "int": 11, "res": 18, "luk": 43},
		{"hp": 33, "atk": 30, "def": 18, "spd": 45, "int": 11, "res": 18, "luk": 44},
		{"hp": 34, "atk": 31, "def": 18, "spd": 46, "int": 12, "res": 19, "luk": 45},
		{"hp": 35, "atk": 32, "def": 19, "spd": 47, "int": 12, "res": 19, "luk": 46},
		{"hp": 35, "atk": 32, "def": 19, "spd": 48, "int": 12, "res": 20, "luk": 47},
		{"hp": 36, "atk": 33, "def": 20, "spd": 49, "int": 12, "res": 20, "luk": 48},
		{"hp": 36, "atk": 33, "def": 20, "spd": 49, "int": 13, "res": 20, "luk": 48},
		{"hp": 37, "atk": 34, "def": 21, "spd": 50, "int": 13, "res": 21, "luk": 49}
	])
	
	_add_class_stats(Enums.ClassID.SHINOBI, Enums.Tier.MASTERY, 20, [
		{"hp": 40, "atk": 40, "def": 23, "spd": 56, "int": 13, "res": 23, "luk": 60},
		{"hp": 41, "atk": 41, "def": 23, "spd": 58, "int": 13, "res": 23, "luk": 63},
		{"hp": 42, "atk": 43, "def": 24, "spd": 60, "int": 13, "res": 24, "luk": 66},
		{"hp": 43, "atk": 45, "def": 25, "spd": 62, "int": 13, "res": 24, "luk": 69},
		{"hp": 44, "atk": 47, "def": 26, "spd": 64, "int": 14, "res": 25, "luk": 72},
		{"hp": 45, "atk": 49, "def": 27, "spd": 66, "int": 14, "res": 26, "luk": 75},
		{"hp": 45, "atk": 50, "def": 27, "spd": 68, "int": 14, "res": 26, "luk": 78},
		{"hp": 46, "atk": 52, "def": 28, "spd": 69, "int": 14, "res": 27, "luk": 81},
		{"hp": 47, "atk": 53, "def": 29, "spd": 71, "int": 15, "res": 28, "luk": 83},
		{"hp": 48, "atk": 53, "def": 29, "spd": 72, "int": 15, "res": 28, "luk": 85},
		{"hp": 48, "atk": 54, "def": 29, "spd": 72, "int": 15, "res": 28, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 15, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 15, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 15, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86},
		{"hp": 48, "atk": 54, "def": 30, "spd": 72, "int": 16, "res": 29, "luk": 86}
	])
	
	# MAGE TREE
	_add_class_stats(Enums.ClassID.MAGE, Enums.Tier.BASE, 10, [
		{"hp": 20, "atk": 8, "def": 9, "spd": 13, "int": 20, "res": 14, "luk": 16},
		{"hp": 21, "atk": 8, "def": 9, "spd": 15, "int": 21, "res": 15, "luk": 16},
		{"hp": 22, "atk": 8, "def": 10, "spd": 16, "int": 23, "res": 16, "luk": 17},
		{"hp": 23, "atk": 9, "def": 11, "spd": 18, "int": 25, "res": 17, "luk": 18},
		{"hp": 24, "atk": 9, "def": 12, "spd": 19, "int": 27, "res": 18, "luk": 19},
		{"hp": 26, "atk": 9, "def": 12, "spd": 21, "int": 28, "res": 19, "luk": 19},
		{"hp": 27, "atk": 9, "def": 13, "spd": 22, "int": 30, "res": 21, "luk": 20},
		{"hp": 28, "atk": 10, "def": 14, "spd": 24, "int": 32, "res": 22, "luk": 21},
		{"hp": 29, "atk": 10, "def": 14, "spd": 24, "int": 33, "res": 23, "luk": 21},
		{"hp": 30, "atk": 10, "def": 15, "spd": 25, "int": 34, "res": 24, "luk": 22}
	])
	
	_add_class_stats(Enums.ClassID.SAGE, Enums.Tier.ASCENSION, 10, [
		{"hp": 33, "atk": 11, "def": 17, "spd": 28, "int": 42, "res": 30, "luk": 24},
		{"hp": 34, "atk": 11, "def": 17, "spd": 28, "int": 43, "res": 31, "luk": 24},
		{"hp": 35, "atk": 11, "def": 18, "spd": 29, "int": 44, "res": 32, "luk": 24},
		{"hp": 36, "atk": 11, "def": 19, "spd": 30, "int": 46, "res": 33, "luk": 25},
		{"hp": 37, "atk": 11, "def": 19, "spd": 31, "int": 47, "res": 34, "luk": 25},
		{"hp": 38, "atk": 12, "def": 20, "spd": 32, "int": 48, "res": 35, "luk": 25},
		{"hp": 38, "atk": 12, "def": 20, "spd": 32, "int": 49, "res": 36, "luk": 26},
		{"hp": 39, "atk": 12, "def": 21, "spd": 33, "int": 50, "res": 37, "luk": 26},
		{"hp": 39, "atk": 12, "def": 21, "spd": 33, "int": 51, "res": 37, "luk": 26},
		{"hp": 40, "atk": 12, "def": 22, "spd": 34, "int": 52, "res": 38, "luk": 27}
	])
	
	_add_class_stats(Enums.ClassID.SUMMONER, Enums.Tier.MASTERY, 20, [
		{"hp": 43, "atk": 13, "def": 24, "spd": 37, "int": 62, "res": 44, "luk": 32},
		{"hp": 44, "atk": 13, "def": 24, "spd": 38, "int": 64, "res": 45, "luk": 33},
		{"hp": 45, "atk": 13, "def": 25, "spd": 39, "int": 66, "res": 47, "luk": 35},
		{"hp": 46, "atk": 14, "def": 26, "spd": 40, "int": 68, "res": 49, "luk": 37},
		{"hp": 47, "atk": 14, "def": 27, "spd": 41, "int": 70, "res": 50, "luk": 39},
		{"hp": 48, "atk": 14, "def": 28, "spd": 42, "int": 72, "res": 52, "luk": 41},
		{"hp": 49, "atk": 15, "def": 28, "spd": 43, "int": 74, "res": 54, "luk": 43},
		{"hp": 50, "atk": 15, "def": 29, "spd": 44, "int": 76, "res": 55, "luk": 45},
		{"hp": 51, "atk": 15, "def": 30, "spd": 46, "int": 78, "res": 57, "luk": 47},
		{"hp": 52, "atk": 15, "def": 30, "spd": 47, "int": 79, "res": 57, "luk": 48},
		{"hp": 53, "atk": 16, "def": 31, "spd": 47, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 47, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49},
		{"hp": 53, "atk": 16, "def": 31, "spd": 48, "int": 80, "res": 58, "luk": 49}
	])
	
	# CLERIC TREE
	_add_class_stats(Enums.ClassID.CLERIC, Enums.Tier.BASE, 10, [
		{"hp": 23, "atk": 6, "def": 10, "spd": 15, "int": 18, "res": 17, "luk": 11},
		{"hp": 24, "atk": 6, "def": 10, "spd": 16, "int": 19, "res": 18, "luk": 11},
		{"hp": 26, "atk": 7, "def": 11, "spd": 17, "int": 21, "res": 19, "luk": 12},
		{"hp": 27, "atk": 7, "def": 12, "spd": 18, "int": 22, "res": 20, "luk": 13},
		{"hp": 29, "atk": 8, "def": 13, "spd": 19, "int": 24, "res": 22, "luk": 14},
		{"hp": 30, "atk": 8, "def": 14, "spd": 20, "int": 25, "res": 23, "luk": 14},
		{"hp": 32, "atk": 9, "def": 15, "spd": 21, "int": 27, "res": 25, "luk": 15},
		{"hp": 33, "atk": 9, "def": 16, "spd": 22, "int": 28, "res": 26, "luk": 16},
		{"hp": 34, "atk": 9, "def": 16, "spd": 22, "int": 29, "res": 27, "luk": 16},
		{"hp": 35, "atk": 10, "def": 17, "spd": 23, "int": 30, "res": 28, "luk": 17}
	])
	
	_add_class_stats(Enums.ClassID.BISHOP, Enums.Tier.ASCENSION, 10, [
		{"hp": 40, "atk": 12, "def": 20, "spd": 25, "int": 36, "res": 34, "luk": 18},
		{"hp": 41, "atk": 12, "def": 20, "spd": 25, "int": 37, "res": 35, "luk": 18},
		{"hp": 42, "atk": 13, "def": 21, "spd": 26, "int": 38, "res": 36, "luk": 18},
		{"hp": 43, "atk": 13, "def": 22, "spd": 27, "int": 39, "res": 37, "luk": 18},
		{"hp": 44, "atk": 14, "def": 23, "spd": 27, "int": 40, "res": 38, "luk": 18},
		{"hp": 46, "atk": 14, "def": 23, "spd": 28, "int": 41, "res": 39, "luk": 18},
		{"hp": 47, "atk": 15, "def": 24, "spd": 28, "int": 42, "res": 39, "luk": 19},
		{"hp": 48, "atk": 15, "def": 25, "spd": 29, "int": 43, "res": 40, "luk": 19},
		{"hp": 48, "atk": 15, "def": 25, "spd": 29, "int": 43, "res": 40, "luk": 19},
		{"hp": 49, "atk": 16, "def": 26, "spd": 30, "int": 44, "res": 41, "luk": 19}
	])
	
	_add_class_stats(Enums.ClassID.PALADIN, Enums.Tier.MASTERY, 20, [
		{"hp": 54, "atk": 24, "def": 34, "spd": 31, "int": 47, "res": 45, "luk": 20},
		{"hp": 55, "atk": 25, "def": 35, "spd": 32, "int": 48, "res": 46, "luk": 20},
		{"hp": 56, "atk": 27, "def": 36, "spd": 33, "int": 49, "res": 48, "luk": 20},
		{"hp": 57, "atk": 29, "def": 38, "spd": 34, "int": 50, "res": 49, "luk": 21},
		{"hp": 58, "atk": 31, "def": 39, "spd": 35, "int": 51, "res": 51, "luk": 21},
		{"hp": 60, "atk": 33, "def": 41, "spd": 36, "int": 53, "res": 52, "luk": 22},
		{"hp": 61, "atk": 35, "def": 42, "spd": 37, "int": 54, "res": 54, "luk": 22},
		{"hp": 62, "atk": 37, "def": 44, "spd": 38, "int": 55, "res": 55, "luk": 23},
		{"hp": 63, "atk": 39, "def": 46, "spd": 39, "int": 57, "res": 57, "luk": 23},
		{"hp": 64, "atk": 39, "def": 47, "spd": 39, "int": 58, "res": 58, "luk": 23},
		{"hp": 65, "atk": 40, "def": 47, "spd": 40, "int": 58, "res": 58, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24},
		{"hp": 65, "atk": 40, "def": 48, "spd": 40, "int": 59, "res": 59, "luk": 24}
	])
	
	# STRIKER TREE
	_add_class_stats(Enums.ClassID.STRIKER, Enums.Tier.BASE, 10, [
		{"hp": 24, "atk": 17, "def": 10, "spd": 16, "int": 6, "res": 10, "luk": 17},
		{"hp": 25, "atk": 18, "def": 10, "spd": 17, "int": 6, "res": 10, "luk": 18},
		{"hp": 27, "atk": 19, "def": 11, "spd": 19, "int": 6, "res": 11, "luk": 19},
		{"hp": 28, "atk": 21, "def": 12, "spd": 20, "int": 7, "res": 12, "luk": 20},
		{"hp": 30, "atk": 22, "def": 13, "spd": 22, "int": 7, "res": 13, "luk": 21},
		{"hp": 31, "atk": 23, "def": 14, "spd": 24, "int": 7, "res": 14, "luk": 22},
		{"hp": 32, "atk": 25, "def": 15, "spd": 25, "int": 8, "res": 15, "luk": 23},
		{"hp": 33, "atk": 26, "def": 16, "spd": 27, "int": 8, "res": 16, "luk": 24},
		{"hp": 34, "atk": 27, "def": 16, "spd": 28, "int": 8, "res": 16, "luk": 24},
		{"hp": 35, "atk": 28, "def": 17, "spd": 29, "int": 9, "res": 17, "luk": 25}
	])
	
	_add_class_stats(Enums.ClassID.PUGILIST, Enums.Tier.ASCENSION, 10, [
		{"hp": 40, "atk": 33, "def": 19, "spd": 35, "int": 9, "res": 22, "luk": 27},
		{"hp": 41, "atk": 34, "def": 19, "spd": 36, "int": 9, "res": 22, "luk": 27},
		{"hp": 42, "atk": 35, "def": 20, "spd": 37, "int": 9, "res": 23, "luk": 27},
		{"hp": 43, "atk": 36, "def": 21, "spd": 38, "int": 9, "res": 24, "luk": 27},
		{"hp": 44, "atk": 37, "def": 21, "spd": 39, "int": 10, "res": 25, "luk": 27},
		{"hp": 45, "atk": 38, "def": 22, "spd": 40, "int": 10, "res": 26, "luk": 27},
		{"hp": 46, "atk": 40, "def": 22, "spd": 41, "int": 10, "res": 27, "luk": 28},
		{"hp": 47, "atk": 41, "def": 23, "spd": 42, "int": 10, "res": 28, "luk": 28},
		{"hp": 47, "atk": 41, "def": 23, "spd": 42, "int": 11, "res": 28, "luk": 28},
		{"hp": 48, "atk": 42, "def": 24, "spd": 43, "int": 11, "res": 29, "luk": 28}
	])
	
	_add_class_stats(Enums.ClassID.MONK, Enums.Tier.MASTERY, 20, [
		{"hp": 53, "atk": 49, "def": 26, "spd": 48, "int": 11, "res": 37, "luk": 31},
		{"hp": 54, "atk": 50, "def": 26, "spd": 49, "int": 11, "res": 38, "luk": 32},
		{"hp": 55, "atk": 52, "def": 27, "spd": 50, "int": 11, "res": 40, "luk": 33},
		{"hp": 56, "atk": 54, "def": 28, "spd": 52, "int": 11, "res": 41, "luk": 35},
		{"hp": 57, "atk": 56, "def": 29, "spd": 53, "int": 12, "res": 43, "luk": 37},
		{"hp": 59, "atk": 58, "def": 30, "spd": 54, "int": 12, "res": 45, "luk": 39},
		{"hp": 60, "atk": 60, "def": 30, "spd": 56, "int": 12, "res": 46, "luk": 41},
		{"hp": 61, "atk": 62, "def": 31, "spd": 57, "int": 12, "res": 48, "luk": 43},
		{"hp": 62, "atk": 64, "def": 32, "spd": 58, "int": 13, "res": 50, "luk": 44},
		{"hp": 63, "atk": 64, "def": 32, "spd": 59, "int": 13, "res": 51, "luk": 45},
		{"hp": 64, "atk": 65, "def": 33, "spd": 60, "int": 13, "res": 52, "luk": 46},
		{"hp": 64, "atk": 65, "def": 33, "spd": 60, "int": 13, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 13, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46},
		{"hp": 65, "atk": 65, "def": 33, "spd": 60, "int": 14, "res": 52, "luk": 46}
	])

static func _add_class_stats(class_id: Enums.ClassID, tier: Enums.Tier, max_level: int, level_stats: Array) -> void:
	class_stats[class_id] = {
		"tier": tier,
		"max_level": max_level,
		"level_stats": level_stats
	}

static func get_stats_for_level(class_id: Enums.ClassID, level: int) -> Dictionary:
	var data: Dictionary = class_stats.get(class_id, {})
	if data.is_empty():
		return {}
	
	var max_level: int = data["max_level"]
	if level < 1 or level > max_level:
		return {}
	
	var level_stats: Array = data["level_stats"]
	return level_stats[level - 1]

static func get_max_level_for_class(class_id: Enums.ClassID) -> int:
	var data: Dictionary = class_stats.get(class_id, {})
	return data.get("max_level", 10)

static func get_class_tier(class_id: Enums.ClassID) -> Enums.Tier:
	var data: Dictionary = class_stats.get(class_id, {})
	return data.get("tier", Enums.Tier.BASE)
