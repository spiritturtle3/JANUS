extends Camera2D

@export var pov_speed: float = 75.0
@export var pov_zoom: float = 1.4
@export var map_size: Vector2 = Vector2(640.0, 360.0)
@export var lens_size: Vector2 = Vector2(270.0, 270.0)

var pov_active := false
var normal_camera: Camera2D


func _ready() -> void:
	enabled = false

	normal_camera = get_tree().current_scene.get_node_or_null(
		"Player/MainCamera"
	)

	if is_instance_valid(normal_camera):
		global_position = normal_camera.global_position


func _process(delta: float) -> void:
	if not pov_active:
		return

	var direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	global_position += direction * pov_speed * delta
	_clamp_camera_position()


func _clamp_camera_position() -> void:
	var half_lens_world := lens_size / (2.0 * pov_zoom)

	var min_position := half_lens_world
	var max_position := map_size - half_lens_world

	global_position.x = clampf(
		global_position.x,
		min_position.x,
		max_position.x
	)

	global_position.y = clampf(
		global_position.y,
		min_position.y,
		max_position.y
	)


func enter_pov() -> void:
	if is_instance_valid(normal_camera):
		global_position = normal_camera.global_position

	pov_active = true
	zoom = Vector2(pov_zoom, pov_zoom)
	enabled = true
	_clamp_camera_position()


func exit_pov() -> void:
	pov_active = false
	enabled = false
