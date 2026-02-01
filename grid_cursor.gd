class_name GridCursor
extends Control
## Visual cursor that follows mouse/keyboard input on the grid.

var current_coord: Vector2i = Vector2i(0, 0)
var cursor_color: Color = Color(1.0, 1.0, 1.0, 1.0)  # White
var line_width: float = 4.0
var corner_length: float = 16.0  # Length of each corner line
var pulse_speed: float = 7.0
var min_alpha: float = 0.4
var max_alpha: float = 1.0
var pulse_time: float = 0.0

func _ready() -> void:
	size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse events
	z_index = 100  # Render above tiles but below units

func setup(start_coord: Vector2i) -> void:
	current_coord = start_coord
	_update_position()

func move_to(coord: Vector2i) -> void:
	current_coord = coord
	_update_position()

func _update_position() -> void:
	position = Vector2(
		current_coord.x * Constants.TILE_SIZE,
		current_coord.y * Constants.TILE_SIZE
	)
	queue_redraw()

func _process(delta: float) -> void:
	pulse_time += delta * pulse_speed
	var alpha: float = lerp(min_alpha, max_alpha, (sin(pulse_time) + 1.0) / 2.0)
	cursor_color.a = alpha
	queue_redraw()

func _draw() -> void:
	# Draw 4 right-angle corners (inverted plus)
	# Top-left corner
	draw_line(Vector2(0, corner_length), Vector2(0, 0), cursor_color, line_width)
	draw_line(Vector2(0, 0), Vector2(corner_length, 0), cursor_color, line_width)
	
	# Top-right corner
	draw_line(Vector2(size.x - corner_length, 0), Vector2(size.x, 0), cursor_color, line_width)
	draw_line(Vector2(size.x, 0), Vector2(size.x, corner_length), cursor_color, line_width)
	
	# Bottom-left corner
	draw_line(Vector2(0, size.y - corner_length), Vector2(0, size.y), cursor_color, line_width)
	draw_line(Vector2(0, size.y), Vector2(corner_length, size.y), cursor_color, line_width)
	
	# Bottom-right corner
	draw_line(Vector2(size.x, size.y - corner_length), Vector2(size.x, size.y), cursor_color, line_width)
	draw_line(Vector2(size.x - corner_length, size.y), Vector2(size.x, size.y), cursor_color, line_width)

func get_coord() -> Vector2i:
	return current_coord
