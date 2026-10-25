extends CanvasLayer

const VIDEO_PATH := "res://transition/static_vid.ogv"
const STATIC_PATH := "res://transition/static_aud.mp3"
const VOICE_PATH := "res://audio/test_subject_failed.wav"
const MENU_SCENE := "res://ui/main_menu.tscn"
const STATIC_DB := -20.0 # lower = quieter
const MUSIC_FADE_TIME := 1.5
const SILENT_DB := -60.0

var busy := false
var nodes: Array[Node] = []


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS


func _fade_out_music() -> void:
	for child in MusicPlayer.get_children():
		if child is AudioStreamPlayer:
			var tw := create_tween()
			tw.tween_property(child, "volume_db", SILENT_DB, MUSIC_FADE_TIME)
			return


func play_ending() -> void:
	if busy:
		return
	busy = true
	get_tree().paused = true

	_fade_out_music()

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var video := VideoStreamPlayer.new()
	video.stream = load(VIDEO_PATH)
	video.expand = true
	video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	video.finished.connect(video.play) # loop the static
	add_child(video)

	var static_snd := AudioStreamPlayer.new()
	static_snd.stream = load(STATIC_PATH)
	static_snd.volume_db = STATIC_DB
	static_snd.finished.connect(static_snd.play) # loop the static
	add_child(static_snd)

	var voice := AudioStreamPlayer.new()
	voice.stream = load(VOICE_PATH)
	voice.finished.connect(_finish)
	add_child(voice)

	nodes = [bg, video, static_snd, voice]

	video.play()
	static_snd.play()
	voice.play()


func _finish() -> void:
	for n in nodes:
		n.queue_free()
	nodes.clear()
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
	busy = false
