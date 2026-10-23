extends CanvasLayer

@onready var dark_overlay: TextureRect = $DarkOverlay
@onready var lens_ring: TextureRect = $LensRing

var pov_active := false
var player: CharacterBody2D
var camera_node: Node2D
var main_camera: Camera2D
var pov_camera: Camera2D
var photo_preview: CanvasLayer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	camera_node = get_tree().get_first_node_in_group("camera_drone")

	main_camera = get_tree().current_scene.get_node_or_null(
		"Player/MainCamera"
	)

	pov_camera = get_tree().current_scene.get_node_or_null(
		"POVCamera"
	)

	photo_preview = get_node_or_null("PhotoPreview")

	dark_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	dark_overlay.z_index = 10
	lens_ring.z_index = 11

	dark_overlay.hide()
	lens_ring.hide()


func _unhandled_input(event: InputEvent) -> void:
	# Ignore camera controls while the photo preview is open.
	if is_instance_valid(photo_preview) and photo_preview.preview_active:
		return

	# E enters camera mode.
	if event.is_action_pressed("camera_mode") and not pov_active:
		set_pov(true)
		get_viewport().set_input_as_handled()
		return

	if not pov_active:
		return

	# Left-click takes a photo.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			take_photo()
			return

	# C exits camera mode without taking a photo.
	if event.is_action_pressed("exit_camera"):
		set_pov(false)
		get_viewport().set_input_as_handled()


func set_pov(active: bool) -> void:
	if pov_active == active:
		return

	pov_active = active

	if is_instance_valid(player):
		if active:
			player.set_camera_idle()
		else:
			player.exit_camera_mode()

	if is_instance_valid(camera_node):
		camera_node.visible = not active

	dark_overlay.visible = active
	lens_ring.visible = active

	if active:
		if is_instance_valid(main_camera):
			main_camera.enabled = false

		if is_instance_valid(pov_camera):
			pov_camera.enter_pov()
	else:
		if is_instance_valid(pov_camera):
			pov_camera.exit_pov()

		if is_instance_valid(main_camera):
			main_camera.enabled = true


func take_photo() -> void:
	# Hide the camera overlay before capturing.
	dark_overlay.hide()
	lens_ring.hide()

	await RenderingServer.frame_post_draw

	var captured_image := get_viewport().get_texture().get_image()
	var captured_texture := ImageTexture.create_from_image(captured_image)

	# Exit POV mode.
	set_pov(false)

	# Display the captured photo.
	if is_instance_valid(photo_preview):
		photo_preview.show_single_photo(captured_texture)
