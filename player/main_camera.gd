extends Camera2D

@export var pov_speed: float = 75.0
@export var pov_zoom: float = 1.4

var pov_active := false
var original_zoom := Vector2.ONE

func _ready() -> void:
	original_zoom = zoom

func _process(delta: float) -> void:
	if not pov_active:
		return

	var direction := Input.get_vector("left", "right", "up", "down")
	global_position += direction * pov_speed * delta

func enter_pov() -> void:
	pov_active = true
	zoom = Vector2(pov_zoom, pov_zoom)

func exit_pov() -> void:
	pov_active = false
	zoom = original_zoom
