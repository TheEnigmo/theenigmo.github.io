class_name PhaseBanner
extends CanvasLayer
## Displays phase transition banners.

signal animation_finished

var label: Label
var tween: Tween
var is_animating: bool = false

func _ready() -> void:
	_create_label()

func _create_label() -> void:
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.modulate.a = 0.0
	add_child(label)

func show_phase(phase: Enums.Phase) -> void:
	if phase == Enums.Phase.PLAYER_PHASE:
		label.text = "Player Phase"
		label.add_theme_color_override("font_color", Color(0.3, 0.5, 1.0))
	else:
		label.text = "Enemy Phase"
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	
	_animate_banner()

func _animate_banner() -> void:
	is_animating = true
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	label.size = Vector2(viewport_size.x, 100)
	label.position = Vector2(viewport_size.x, viewport_size.y / 2.0 - 50)
	label.modulate.a = 1.0
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(label, "position:x", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(0.8)
	tween.tween_property(label, "position:x", -viewport_size.x, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_on_animation_finished)

func _on_animation_finished() -> void:
	label.modulate.a = 0.0
	is_animating = false
	animation_finished.emit()
