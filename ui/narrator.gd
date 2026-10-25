extends CanvasLayer

const MONOLOGUE_FADE := 0.4
const NOTIFY_FADE := 0.3
const TYPE_SPEED := 0.03 # seconds per character

const CYAN := Color(0.0, 0.9, 1.0)
const MAGENTA := Color(1.0, 0.2, 0.6)
const TEXT_COLOR := Color(0.8, 0.95, 1.0)
const BG_COLOR := Color(0.03, 0.05, 0.09, 0.78)

var monologue_panel: PanelContainer
var monologue_label: Label
var notify_panel: PanelContainer
var notify_label: Label
var voice: AudioStreamPlayer
var monologue_tween: Tween
var notify_tween: Tween


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Monologue: bottom center, cyan
	var m := _make_panel(CYAN, 380.0)
	monologue_panel = m[0]
	monologue_label = m[1]
	monologue_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	monologue_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	monologue_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	monologue_panel.offset_bottom = -24

	# Notification: top right, magenta, wraps at 300 px
	var n := _make_panel(MAGENTA, 300.0)
	notify_panel = n[0]
	notify_label = n[1]
	notify_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	notify_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	notify_panel.offset_top = 16
	notify_panel.offset_right = -16

	voice = AudioStreamPlayer.new()
	add_child(voice)


func _make_panel(accent: Color, min_width: float) -> Array:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(
		["Consolas", "Courier New", "DejaVu Sans Mono", "monospace"]
	)

	var box := StyleBoxFlat.new()
	box.bg_color = BG_COLOR
	box.set_border_width_all(1)
	box.border_width_left = 3
	box.border_color = Color(accent, 0.7)
	box.set_content_margin_all(6)
	box.content_margin_left = 10
	box.content_margin_right = 10

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", box)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.modulate.a = 0.0

	var label := Label.new()
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if min_width > 0.0:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = min_width

	panel.add_child(label)
	add_child(panel)
	return [panel, label]


func monologue(text: String, duration: float = 4.0, audio: AudioStream = null) -> void:
	monologue_label.text = text
	monologue_label.visible_ratio = 0.0
	monologue_panel.reset_size.call_deferred()
	if audio:
		voice.stream = audio
		voice.play()

	if monologue_tween:
		monologue_tween.kill()
	monologue_tween = create_tween()
	monologue_tween.tween_property(monologue_panel, "modulate:a", 1.0, MONOLOGUE_FADE)
	monologue_tween.parallel().tween_property(
		monologue_label, "visible_ratio", 1.0, text.length() * TYPE_SPEED
	)
	monologue_tween.tween_interval(duration)
	monologue_tween.tween_property(monologue_panel, "modulate:a", 0.0, MONOLOGUE_FADE)


func notify(text: String, duration: float = 3.0) -> void:
	notify_label.text = "// " + text.to_upper()
	notify_panel.size = Vector2.ZERO
	notify_panel.reset_size.call_deferred()

	if notify_tween:
		notify_tween.kill()
	notify_tween = create_tween()
	notify_tween.tween_property(notify_panel, "modulate:a", 1.0, NOTIFY_FADE)
	notify_tween.tween_interval(duration)
	notify_tween.tween_property(notify_panel, "modulate:a", 0.0, NOTIFY_FADE)
