extends CanvasLayer
# Autoload as "CutscenePlayer". Usage: await CutscenePlayer.play(slides)

signal finished

const FADE_TIME: float = 0.4

var root: Control
var rect: TextureRect
var playlist: Array[CutsceneSlide] = []
var index: int = 0
var busy: bool = false
var playing: bool = false
var was_paused: bool = false
var token: int = 0  # invalidates old auto-advance timers


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS

	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.visible = false
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	rect = TextureRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(rect)


func play(slides: Array) -> void:
	if playing:
		return

	playlist.clear()
	for s in slides:
		if s == null or s.texture == null:
			continue
		if s.if_level == 0 or StoryMemory.get_choice(s.if_level) == s.if_choice:
			playlist.append(s)
	if playlist.is_empty():
		return

	playing = true
	index = 0
	was_paused = get_tree().paused
	get_tree().paused = true  # freezes the level and its buttons

	root.visible = true
	rect.texture = playlist[0].texture
	rect.modulate.a = 0.0
	busy = true
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 1.0, FADE_TIME)
	t.tween_callback(_slide_shown)

	await finished


func _slide_shown() -> void:
	busy = false
	var d: float = playlist[index].duration
	if d > 0.0:
		token += 1
		get_tree().create_timer(d).timeout.connect(_on_auto_timer.bind(token))


func _on_auto_timer(t: int) -> void:
	if t == token and playing and not busy:
		_advance()


func _input(event: InputEvent) -> void:
	if not playing:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()
	elif event.is_action_pressed("ui_accept") \
			or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	if busy:
		return
	index += 1
	if index >= playlist.size():
		_finish()
		return
	busy = true
	token += 1
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 0.0, FADE_TIME)
	t.tween_callback(_swap_texture)
	t.tween_property(rect, "modulate:a", 1.0, FADE_TIME)
	t.tween_callback(_slide_shown)


func _swap_texture() -> void:
	rect.texture = playlist[index].texture


func _finish() -> void:
	busy = true
	token += 1
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 0.0, FADE_TIME)
	t.tween_callback(_close)


func _close() -> void:
	root.visible = false
	get_tree().paused = was_paused
	playing = false
	busy = false
	finished.emit()
