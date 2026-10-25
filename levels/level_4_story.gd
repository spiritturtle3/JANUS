extends Node

@export var gate: Node2D
@export var choice_left_texture: Texture2D
@export var choice_right_texture: Texture2D
@export_file("*.tscn") var main_menu_scene: String = ""  # no longer used, EndingSequence handles the menu
@export var after_choice_slides: Array[CutsceneSlide] = []  # plays after the player picks

@onready var pov_camera: Camera2D = get_parent().get_node("POVCamera")
@onready var camera_ui: CanvasLayer = get_parent().get_node("CameraUI")
@onready var photo_preview: CanvasLayer = camera_ui.get_node("PhotoPreview")

var choices_visible: bool = false
var story_completed: bool = false


func _ready() -> void:
	add_to_group("level_story")
	print("Level 4 story controller ready.")


func is_gate_in_photo() -> bool:
	if not is_instance_valid(gate) or not is_instance_valid(pov_camera):
		return false

	var lens_radius: float = pov_camera.lens_size.x / (2.0 * pov_camera.pov_zoom)
	var distance: float = gate.global_position.distance_to(pov_camera.global_position)

	return distance <= lens_radius


func try_show_choices() -> bool:
	if story_completed or choices_visible:
		return false

	if not is_gate_in_photo():
		return false

	choices_visible = true
	photo_preview.show_choices(choice_left_texture, choice_right_texture)
	print("Level 4: Showing choice cards.")
	return true


func on_choice_selected(index: int) -> void:
	StoryMemory.set_choice(4, index)
	choices_visible = false
	story_completed = true
	print("Level 4: Choice selected: ", index)

	await CutscenePlayer.play(after_choice_slides)

	EndingSequence.play_ending()
