extends CanvasLayer
# Autoload as "SceneTransition". Usage: SceneTransition.go_to("res://levels/level_2.tscn")

const STATIC_VIDEO: VideoStream = preload("res://transition/static_vid.ogv")
const STATIC_AUDIO: AudioStream = preload("res://transition/static_aud.mp3")

# Seconds into the static when the scene is swapped (static fully covers the screen)
const SWAP_TIME: float = 0.6

var video: VideoStreamPlayer
var audio: AudioStreamPlayer
var busy: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	video = VideoStreamPlayer.new()
	video.stream = STATIC_VIDEO
	video.expand = true
	video.loop = false
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	video.visible = false
	add_child(video)

	audio = AudioStreamPlayer.new()
	audio.stream = STATIC_AUDIO
	add_child(audio)


func go_to(scene_path: String) -> void:
	if busy:
		return
	busy = true
	get_tree().paused = true  # freeze the player and NPCs during the static

	video.visible = true
	video.play()
	audio.play()

	await get_tree().create_timer(SWAP_TIME).timeout
	get_tree().change_scene_to_file(scene_path)
	get_tree().paused = false

	if video.is_playing():
		await video.finished
	video.visible = false
	busy = false
