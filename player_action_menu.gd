class_name PlayerActionMenu
extends BaseMenu
## Displays player-level actions like End Phase.

func _ready() -> void:
	panel_width = 140
	button_height = 32
	super._ready()

func show_player_menu(screen_position: Vector2) -> void:
	_clear_options()
	add_option("End Phase", "end_phase", true)
	show_menu(screen_position)
