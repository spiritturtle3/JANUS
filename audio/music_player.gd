extends Node
# Autoload as "MusicPlayer".
# Plays the menu track on the main menu and the BGM on every other scene.

var MENU_TRACK: AudioStreamMP3 = preload("res://audio/start_menu.mp3")
var GAME_TRACK: AudioStreamMP3 = preload("res://audio/bgm.mp3")
const MENU_SCENE: String = "res://ui/main_menu.tscn"

const PLAY_DB: float = -8.0     # normal music volume
const SILENT_DB: float = -60.0
const FADE_TIME: float = 1.0

var player: AudioStreamPlayer
var tween: Tween
var current_track: AudioStream
var last_scene_path: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep playing while the game is paused

	MENU_TRACK.loop = true
	GAME_TRACK.loop = true

	player = AudioStreamPlayer.new()
	player.volume_db = SILENT_DB
	add_child(player)


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var path := scene.scene_file_path
	if path == last_scene_path:
		return
	last_scene_path = path

	if path == MENU_SCENE:
		_switch_to(MENU_TRACK)
	else:
		_switch_to(GAME_TRACK)


func _switch_to(track: AudioStream) -> void:
	if track == current_track:
		return
	current_track = track

	if tween:
		tween.kill()
	tween = create_tween()

	if player.playing:
		tween.tween_property(player, "volume_db", SILENT_DB, FADE_TIME)
	tween.tween_callback(_start_track.bind(track))
	tween.tween_property(player, "volume_db", PLAY_DB, FADE_TIME)


func _start_track(track: AudioStream) -> void:
	player.stream = track
	player.play()


func fade_out(time: float = 1.5) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(player, "volume_db", SILENT_DB, time)
