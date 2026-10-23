extends CanvasLayer

@onready var background_single: TextureRect = $BackgroundSingle
@onready var background_choice: TextureRect = $BackgroundChoice
@onready var photo_image: TextureRect = $PhotoImage
@onready var frame_left: TextureRect = $FrameLeft
@onready var frame_right: TextureRect = $FrameRight
@onready var left_image: TextureRect = $LeftImage
@onready var right_image: TextureRect = $RightImage

var preview_active: bool = false
var choice_mode: bool = false
var selected_index: int = 0

const SELECTED_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const DIMMED_COLOR := Color(0.45, 0.45, 0.45, 1.0)


func _ready() -> void:
	hide_preview()


func _unhandled_input(event: InputEvent) -> void:
	if not preview_active:
		return

	if choice_mode:
		if event.is_action_pressed("ui_left") or event.is_action_pressed("left"):
			selected_index = 0
			_update_selection()
			get_viewport().set_input_as_handled()
			return

		if event.is_action_pressed("ui_right") or event.is_action_pressed("right"):
			selected_index = 1
			_update_selection()
			get_viewport().set_input_as_handled()
			return

		if event.is_action_pressed("ui_accept"):
			var chosen := selected_index
			get_viewport().set_input_as_handled()
			hide_preview()
			get_tree().call_group("level_story", "on_choice_selected", chosen)
			return

		return

	if event.is_action_pressed("ui_accept"):
		hide_preview()
		get_viewport().set_input_as_handled()


func _update_selection() -> void:
	var left_selected := selected_index == 0
	var right_selected := selected_index == 1

	frame_left.visible = left_selected
	frame_right.visible = right_selected

	left_image.modulate = SELECTED_COLOR if left_selected else DIMMED_COLOR
	right_image.modulate = SELECTED_COLOR if right_selected else DIMMED_COLOR

	frame_left.modulate = SELECTED_COLOR
	frame_right.modulate = SELECTED_COLOR


func hide_preview() -> void:
	preview_active = false
	choice_mode = false

	background_single.hide()
	background_choice.hide()
	photo_image.hide()
	frame_left.hide()
	frame_right.hide()
	left_image.hide()
	right_image.hide()


func show_single_photo(captured_texture: Texture2D) -> void:
	hide_preview()

	var story := get_tree().get_first_node_in_group("level_story")
	if story != null and story.try_show_choices():
		return

	photo_image.texture = captured_texture
	background_single.show()
	photo_image.show()
	preview_active = true

	get_tree().call_group("tutorial_ui", "on_photo_preview_opened")


func show_choices(left_texture: Texture2D, right_texture: Texture2D) -> void:
	hide_preview()

	left_image.texture = left_texture
	right_image.texture = right_texture

	background_choice.show()
	left_image.show()
	right_image.show()

	selected_index = 0
	_update_selection()

	choice_mode = true
	preview_active = true
