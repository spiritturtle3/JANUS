extends CanvasLayer
## LevelTransition (Autoload) - sized for a 640x360 viewport
## End of level:  camera task check  ->  hacker puzzle  ->  next level
## Start of level (2-4): if the previous puzzle is unsolved, it is shown again.

# ---------- PATHS ----------
const LEVEL_SCENES := {
	1: "res://levels/level_1.tscn",
	2: "res://levels/level_2.tscn",
	3: "res://levels/level_3.tscn",
	4: "res://levels/level_4.tscn",
}
const END_SCENE := "res://ui/main_menu.tscn"
const LAST_LEVEL := 4

# ---------- PUZZLES (easy) ----------
const PUZZLES := {
	1: {
		"prompt": "INTERCEPTED SIGNAL:\nERUTPAC",
		"hint": "Read it backwards.",
		"answer": "CAPTURE",
	},
	2: {
		"prompt": "INTERCEPTED SIGNAL:\nDBNFSB",
		"hint": "Every letter is 1 step ahead. Go back 1 (D becomes C).",
		"answer": "CAMERA",
	},
	3: {
		"prompt": "INTERCEPTED SIGNAL:\n2   4   8   16   ?",
		"hint": "Each number doubles.",
		"answer": "32",
	},
}

# ---------- SIZES (tweak these if anything looks too big or small) ----------
const PANEL_WIDTH := 440.0
const FS_TITLE := 16
const FS_PROMPT := 15
const FS_BODY := 11
const FS_SMALL := 10

# ---------- COLORS ----------
const CYAN := Color("00f0ff")
const MAGENTA := Color("ff00aa")
const PURPLE := Color("8a00c8")
const GREEN := Color("00ff88")
const PANEL_BG := Color("0a0a1a")

const BLUR_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
void fragment() {
	vec3 c = textureLod(screen_tex, SCREEN_UV, blur_amount).rgb;
	COLOR = vec4(c * 0.45, 1.0);
}
"""

# ---------- STATE ----------
var current_level: int = 1
var camera_done: Dictionary = {}
var puzzles_solved: Dictionary = {}
var _root: Control = null


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS


# ======================= PUBLIC API =======================

func reset_progress() -> void:
	camera_done.clear()
	puzzles_solved.clear()
	current_level = 1


func mark_camera_done() -> void:
	camera_done[current_level] = true


func enter_level(level: int) -> void:
	current_level = level
	if level >= 2 and not puzzles_solved.get(level - 1, false):
		_show_puzzle.call_deferred(level - 1, false)


func end_level(level: int) -> void:
	if _root != null:
		return
	current_level = level
	_show_camera_check(level)


func is_open() -> bool:
	return _root != null


# ======================= CAMERA CHECK =======================

func _show_camera_check(level: int) -> void:
	var box := _open_panel()
	box.add_child(_label("MISSION CHECK // LEVEL %d" % level, FS_TITLE, CYAN))
	box.add_child(_label("Have you completed the camera task in this level?", FS_BODY, Color.WHITE))
	var status := _label("", FS_SMALL, MAGENTA)
	box.add_child(status)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	row.add_child(_button("YES, TASK DONE", _on_camera_yes.bind(level, status)))
	row.add_child(_button("NOT YET", _close_panel))


func _on_camera_yes(level: int, status: Label) -> void:
	if camera_done.get(level, false):
		if level >= LAST_LEVEL:
			_go_to(END_SCENE)
		else:
			_show_puzzle(level, true)
	else:
		status.text = "NO PHOTO DETECTED. Capture your target first."


# ======================= HACKER PUZZLE =======================

func _show_puzzle(level: int, load_next: bool) -> void:
	var data: Dictionary = PUZZLES[level]
	var box := _open_panel()
	box.add_child(_label("FIREWALL BREACH // NODE %d" % level, FS_TITLE, CYAN))
	if not load_next:
		box.add_child(_label("Puzzle not solved yet. Solve it to continue.", FS_SMALL, MAGENTA))
	box.add_child(_label(data["prompt"], FS_PROMPT, GREEN))
	box.add_child(_label("HINT: " + data["hint"], FS_SMALL, Color("9aa0c0")))

	var input := LineEdit.new()
	input.placeholder_text = "> enter access code"
	input.custom_minimum_size = Vector2(0, 28)
	input.add_theme_font_size_override("font_size", FS_BODY + 2)
	_style_input(input)
	box.add_child(input)

	var status := _label("", FS_SMALL, MAGENTA)
	box.add_child(status)

	input.text_submitted.connect(_check_answer.bind(level, load_next, status))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	row.add_child(_button("SUBMIT", func(): _check_answer(input.text, level, load_next, status)))
	input.grab_focus()


func _check_answer(text: String, level: int, load_next: bool, status: Label) -> void:
	if text.strip_edges().to_upper() == PUZZLES[level]["answer"]:
		puzzles_solved[level] = true
		status.add_theme_color_override("font_color", GREEN)
		status.text = "ACCESS GRANTED"
		await get_tree().create_timer(1.0, true).timeout
		if load_next:
			_go_to(LEVEL_SCENES[level + 1])
		else:
			_close_panel()
	else:
		status.add_theme_color_override("font_color", MAGENTA)
		status.text = "ACCESS DENIED. Try again."


# ======================= UI HELPERS =======================

func _open_panel() -> VBoxContainer:
	_clear_ui()
	get_tree().paused = true

	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var blur := ColorRect.new()
	blur.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = BLUR_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	blur.material = mat
	_root.add_child(blur)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL_BG
	sb.set_border_width_all(2)
	sb.border_color = CYAN
	sb.set_corner_radius_all(4)
	sb.shadow_color = PURPLE
	sb.shadow_size = 8
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	return box


func _label(text_value: String, font_px: int, font_col: Color) -> Label:
	var l := Label.new()
	l.text = text_value
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font_px)
	l.add_theme_color_override("font_color", font_col)
	return l


func _button(text_value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = Vector2(130, 30)
	b.add_theme_font_size_override("font_size", FS_BODY)
	b.add_theme_color_override("font_color", CYAN)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = PURPLE if state == "hover" else Color("12122a")
		sb.set_border_width_all(1)
		sb.border_color = MAGENTA if state == "hover" else CYAN
		sb.set_corner_radius_all(3)
		b.add_theme_stylebox_override(state, sb)
	b.pressed.connect(callback)
	return b


func _style_input(input: LineEdit) -> void:
	for state in ["normal", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("12122a")
		sb.set_border_width_all(1)
		sb.border_color = MAGENTA if state == "focus" else CYAN
		sb.set_corner_radius_all(3)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		input.add_theme_stylebox_override(state, sb)
	input.add_theme_color_override("font_color", GREEN)
	input.add_theme_color_override("caret_color", GREEN)
	input.add_theme_color_override("font_placeholder_color", Color("5a6080"))


func _clear_ui() -> void:
	if _root != null:
		_root.queue_free()
		_root = null


func _close_panel() -> void:
	_clear_ui()
	get_tree().paused = false


func _go_to(path: String) -> void:
	_clear_ui()
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
