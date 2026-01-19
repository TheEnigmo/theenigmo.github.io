class_name PathVisual
extends Node2D
## Draws movement path arrows on the grid.

var path: Array[Vector2i] = []
var arrow_color: Color = Color(1.0, 1.0, 0.3, 0.9)
var arrow_width: float = 20.0

func set_path(new_path: Array[Vector2i]) -> void:
	path = new_path
	queue_redraw()

func clear_path() -> void:
	path = []
	queue_redraw()

func _draw() -> void:
	if path.size() < 1:
		return
	
	var points: Array[Vector2] = []
	
	var unit_coord: Vector2i = _get_unit_coord()
	var start_edge: Vector2 = _get_edge_between(unit_coord, path[0])
	points.append(start_edge)
	
	for i in range(path.size()):
		points.append(_get_tile_center(path[i]))
	
	if points.size() < 2:
		return
	
	# Draw each segment as a rectangle
	for i in range(points.size() - 1):
		_draw_segment(points[i], points[i + 1])
	
	# Draw circles at joints (not at start)
	for i in range(1, points.size() - 1):
		draw_circle(points[i], arrow_width / 2.0, arrow_color)
	
	_draw_arrowhead(points[-1], points[-2])

func _get_unit_coord() -> Vector2i:
	var grid: Grid = get_parent() as Grid
	if grid and grid.selected_unit:
		return grid.selected_unit.data.coordinate
	return Vector2i.ZERO

func _get_edge_between(from: Vector2i, to: Vector2i) -> Vector2:
	var from_center: Vector2 = _get_tile_center(from)
	var to_center: Vector2 = _get_tile_center(to)
	return (from_center + to_center) / 2.0

func _get_tile_center(coord: Vector2i) -> Vector2:
	return Vector2(
		coord.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0,
		coord.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0
	)

func _draw_segment(from: Vector2, to: Vector2) -> void:
	var direction: Vector2 = (to - from).normalized()
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
	var offset: Vector2 = perpendicular * arrow_width / 2.0
	
	var p1: Vector2 = from + offset
	var p2: Vector2 = from - offset
	var p3: Vector2 = to - offset
	var p4: Vector2 = to + offset
	
	draw_polygon([p1, p4, p3, p2], [arrow_color])

func _draw_arrowhead(tip: Vector2, previous: Vector2) -> void:
	var direction: Vector2 = (tip - previous).normalized()
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
	
	var head_length: float = 32.0
	var head_width: float = 40.0
	
	var arrow_tip: Vector2 = tip + direction * head_length * 0.5
	var back_center: Vector2 = tip - direction * head_length * 0.3
	var left: Vector2 = back_center + perpendicular * head_width * 0.5
	var right: Vector2 = back_center - perpendicular * head_width * 0.5
	
	draw_polygon([arrow_tip, left, right], [arrow_color])
	draw_circle(back_center, arrow_width / 2.0, arrow_color)
