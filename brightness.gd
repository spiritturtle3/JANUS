extends Node

var canvas_modulate: CanvasModulate
var brightness: float = 1.0

func _ready() -> void:
	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)
	set_brightness(brightness)

func set_brightness(value: float) -> void:
	brightness = clampf(value, 0.2, 1.0)
	canvas_modulate.color = Color(brightness, brightness, brightness, 1.0)
