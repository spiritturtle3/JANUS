extends VBoxContainer

var buttons: Array[Button] = []
var selected_index := 0

func _ready() -> void:
	for child in get_children():
		if child is Button:
			buttons.append(child)
			child.mouse_entered.connect(_on_mouse_entered.bind(child))

	if buttons.is_empty():
		return

	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL

	_select_button(0)

func _unhandled_input(event: InputEvent) -> void:
	if buttons.is_empty():
		return

	if event.is_action_pressed("ui_down"):
		_select_button((selected_index + 1) % buttons.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_select_button((selected_index - 1 + buttons.size()) % buttons.size())
		get_viewport().set_input_as_handled()

func _on_mouse_entered(button: Button) -> void:
	var index := buttons.find(button)
	if index >= 0:
		_select_button(index)

func _select_button(index: int) -> void:
	if buttons.is_empty():
		return

	selected_index = wrapi(index, 0, buttons.size())

	for i in range(buttons.size()):
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT

		if i == selected_index:
			style.border_color = Color("#00F0FF")
			style.border_width_left = 2

		buttons[i].add_theme_stylebox_override("normal", style)
		buttons[i].add_theme_stylebox_override("hover", style)
		buttons[i].add_theme_stylebox_override("focus", style)
		buttons[i].add_theme_stylebox_override("pressed", style)

		buttons[i].add_theme_color_override(
			"font_color",
			Color("#00F0FF") if i == selected_index else Color("#E6E0FF")
		)
