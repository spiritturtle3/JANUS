extends Node
var tutorial_shown: bool = false

const SAVE_PATH := "user://save.cfg"
const MAIN_MENU_SCENE := "res://ui/main_menu.tscn"
const INTRO_SCENE := "res://cutscenes/cutscene_intro.tscn"

# Add every new level to this list, in order.

const LEVELS := [
	"res://levels/level_1.tscn",

]

var current_level_index := 0

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func new_game() -> void:
	StoryMemory.reset()  # forget choices from any previous run
	current_level_index = 0
	save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file(INTRO_SCENE)

func continue_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		current_level_index = cfg.get_value("progress", "level", 0)
	load_level(current_level_index)

func load_level(index: int) -> void:
	get_tree().paused = false
	if index >= LEVELS.size():
		go_to_main_menu()
		return
	current_level_index = index
	save_game()
	get_tree().change_scene_to_file(LEVELS[index])

func next_level() -> void:
	load_level(current_level_index + 1)

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func go_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func quit_game() -> void:
	get_tree().quit()

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "level", current_level_index)
	cfg.save(SAVE_PATH)
