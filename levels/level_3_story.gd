extends Node

@export var woman: Sprite2D
@export var dead_texture: Texture2D
@export var blood_texture: Texture2D
@export var choice_left_texture: Texture2D
@export var choice_right_texture: Texture2D
@export var dead_rotation_degrees: float = 0.0
@export var dead_scale_multiplier: float = 1.0
@export var blood_scale_multiplier: float = 1.0

@onready var pov_camera: Camera2D = get_parent().get_node("POVCamera")
@onready var camera_ui: CanvasLayer = get_parent().get_node("CameraUI")
@onready var photo_preview: CanvasLayer = camera_ui.get_node("PhotoPreview")
@onready var level_exit: Area2D = get_parent().get_node("LevelExit")

var choices_visible: bool = false
var story_completed: bool = false


func _ready() -> void:
	add_to_group("level_story")
	print("Level 3 story controller ready.")


func is_woman_in_photo() -> bool:
	if not is_instance_valid(woman) or not is_instance_valid(pov_camera):
		return false

	var lens_radius: float = pov_camera.lens_size.x / (2.0 * pov_camera.pov_zoom)
	var distance: float = woman.global_position.distance_to(pov_camera.global_position)

	return distance <= lens_radius


func try_show_choices() -> bool:
	print("Level 3: try_show_choices called")

	if story_completed or choices_visible:
		print("Level 3: already completed or visible")
		return false

	if woman == null:
		print("Level 3: Woman slot is empty in the Inspector")
		return false

	if not is_woman_in_photo():
		print("Level 3: woman not inside lens")
		return false

	if choice_left_texture == null or choice_right_texture == null:
		print("Level 3: choice textures are empty in the Inspector")

	choices_visible = true
	photo_preview.show_choices(choice_left_texture, choice_right_texture)
	level_exit.unlock()
	print("Level 3: Showing choice cards. Exit unlocked.")
	return true


func on_choice_selected(index: int) -> void:
	choices_visible = false
	story_completed = true
	print("Level 3: Choice selected: ", index)

	var original_scale: Vector2 = woman.scale

	var blood := Sprite2D.new()
	blood.texture = blood_texture
	var holder := woman.get_parent()
	holder.add_child(blood)
	holder.move_child(blood, woman.get_index())
	blood.position = woman.position
	blood.offset = woman.offset
	blood.scale = original_scale * blood_scale_multiplier

	woman.texture = dead_texture
	woman.rotation_degrees = dead_rotation_degrees
	woman.scale = original_scale * dead_scale_multiplier
