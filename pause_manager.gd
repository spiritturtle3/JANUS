extends CanvasLayer

const PAUSE_MENU_SCENE := "res://ui/pause_menu.tscn"

var menu: Control

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	menu = load(PAUSE_MENU_SCENE).instantiate()
	add_child(menu)
	menu.hide()

	var options := menu.get_node("PAUSE OPTIONS")
	options.get_node("RESUMEBUTTON").pressed.connect(resume)
	options.get_node("RESTARTBUTTON").pressed.connect(_on_restart)
	options.get_node("MAINMENUBUTTON").pressed.connect(_on_main_menu)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _on_main_menu_scene():
		return
	if menu.visible:
		resume()
	else:
		pause()
	get_viewport().set_input_as_handled()

func pause() -> void:
	menu.show()
	get_tree().paused = true

func resume() -> void:
	menu.hide()
	get_tree().paused = false

func _on_restart() -> void:
	menu.hide()
	GameManager.restart_level()

func _on_main_menu() -> void:
	menu.hide()
	GameManager.go_to_main_menu()

func _on_main_menu_scene() -> bool:
	var scene := get_tree().current_scene
	return scene == null or scene.scene_file_path == GameManager.MAIN_MENU_SCENE
