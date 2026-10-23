extends Control


@onready var brightness_slider: HSlider = $"PAUSE OPTIONS/brightnessslider"

func _ready() -> void:
	brightness_slider.min_value = 0.2
	brightness_slider.max_value = 1.0
	brightness_slider.step = 0.01
	brightness_slider.value = Brightness.brightness
	brightness_slider.value_changed.connect(_on_brightness_changed)

func _on_brightness_changed(value: float) -> void:
	Brightness.set_brightness(value)
