extends Node

@export var beyond_sludge_x: float = 275.0

@onready var robot: CharacterBody2D = get_parent().get_node("RoboNPC")
@onready var robot_sprite: AnimatedSprite2D = robot.get_node("AnimatedSprite2D")
@onready var pov_camera: Camera2D = get_parent().get_node("POVCamera")
@onready var camera_ui: CanvasLayer = get_parent().get_node("CameraUI")
@onready var photo_preview: CanvasLayer = camera_ui.get_node("PhotoPreview")

var choices_visible: bool = false
var story_completed: bool = false

var fall_texture: Texture2D = preload("res://choices/level_2/fall.png")
var no_fall_texture: Texture2D = preload("res://choices/level_2/no_fall.png")


func _ready() -> void:
	add_to_group("level_story")
	print("Level 2 story controller ready.")


func is_robot_in_photo() -> bool:
	if not is_instance_valid(robot) or not is_instance_valid(pov_camera):
		return false

	var lens_radius: float = pov_camera.lens_size.x / (2.0 * pov_camera.pov_zoom)
	var distance: float = robot.global_position.distance_to(pov_camera.global_position)

	return distance <= lens_radius


func try_show_choices() -> bool:
	if story_completed or choices_visible:
		return false

	if not is_instance_valid(robot):
		return false

	if not robot.has_stopped:
		return false

	if not is_robot_in_photo():
		return false

	choices_visible = true
	photo_preview.show_choices(fall_texture, no_fall_texture)
	print("Level 2: Showing choice cards.")
	return true


func on_choice_selected(index: int) -> void:
	choices_visible = false
	story_completed = true
	print("Level 2: Choice selected: ", index)

	robot.global_position.x = beyond_sludge_x
	robot_sprite.play("up")
	robot_sprite.set_frame_and_progress(1, 0.0)
	robot_sprite.pause()
