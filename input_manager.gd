extends Node
## Centralized input management for keyboard, mouse, and controller.

# Keyboard/Controller action detection
func is_move_up_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_W or event.keycode == KEY_UP
	return false

func is_move_down_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_S or event.keycode == KEY_DOWN
	return false

func is_move_left_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_A or event.keycode == KEY_LEFT
	return false

func is_move_right_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_D or event.keycode == KEY_RIGHT
	return false

func is_confirm_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_F
	if event is InputEventMouseButton and event.pressed:
		return event.button_index == MOUSE_BUTTON_LEFT
	return false

func is_cancel_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_X
	if event is InputEventMouseButton and event.pressed:
		return event.button_index == MOUSE_BUTTON_RIGHT
	return false

func get_movement_direction(event: InputEvent) -> Vector2i:
	if is_move_up_pressed(event):
		return Vector2i.UP
	if is_move_down_pressed(event):
		return Vector2i.DOWN
	if is_move_left_pressed(event):
		return Vector2i.LEFT
	if is_move_right_pressed(event):
		return Vector2i.RIGHT
	return Vector2i.ZERO
