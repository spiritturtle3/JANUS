extends Control

@export var slides: Array[CutsceneSlide] = []
@export_file("*.tscn") var next_scene: String
@export var use_static_exit: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	await get_tree().process_frame
	await CutscenePlayer.play(slides)

	if use_static_exit:
		SceneTransition.go_to(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)
