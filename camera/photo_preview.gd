extends CanvasLayer

@onready var background_single: TextureRect = $BackgroundSingle
@onready var background_choice: TextureRect = $BackgroundChoice
@onready var photo_image: TextureRect = $PhotoImage
@onready var frame_left: TextureRect = $FrameLeft
@onready var frame_right: TextureRect = $FrameRight

var preview_active: bool = false


func _ready() -> void:
	hide_preview()


func _unhandled_input(event: InputEvent) -> void:
	if not preview_active:
		return

	if event.is_action_pressed("ui_accept"):
		hide_preview()
		get_viewport().set_input_as_handled()


func hide_preview() -> void:
	preview_active = false
	background_single.hide()
	background_choice.hide()
	photo_image.hide()
	frame_left.hide()
	frame_right.hide()


func show_single_photo(captured_texture: Texture2D) -> void:
	hide_preview()
	photo_image.texture = captured_texture
	background_single.show()
	photo_image.show()
	preview_active = true

	get_tree().call_group("tutorial_ui", "on_photo_preview_opened")
