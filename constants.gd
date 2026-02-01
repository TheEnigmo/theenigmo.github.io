class_name Constants
## Central repository for all game constants.

# Grid
const GRID_WIDTH: int = 9
const GRID_HEIGHT: int = 9
const TILE_SIZE: int = 64  # Pixels per tile

# Movement ranges by weight class
const MOVEMENT_HEAVY: int = 3
const MOVEMENT_STANDARD: int = 4
const MOVEMENT_LIGHT: int = 5

# Combat
const BASE_HIT_CHANCE: float = 0.95
const SPD_HIT_MODIFIER: float = 0.0025  # Per point of SPD
const CRIT_LUK_MODIFIER: float = 0.003  # Per point of LUK
const CRIT_DAMAGE_MULTIPLIER: float = 2.0
const DOUBLE_ATTACK_SPD_THRESHOLD: int = 5

# Class matchup modifier
const CLASS_ADVANTAGE_MODIFIER: float = 0.10

# Element modifiers
const ELEMENT_ADVANTAGE_MODIFIER: float = 0.10
