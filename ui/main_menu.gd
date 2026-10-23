extends Node2D

@onready var continue_button: BaseButton = $MenuContainer/ContinueButton
@onready var new_game_button: BaseButton = $MenuContainer/NewGameButton
@onready var load_game_button: BaseButton = $MenuContainer/LoadGameButton
@onready var settings_button: BaseButton = $MenuContainer/SettingsButton
@onready var quit_button: BaseButton = $MenuContainer/QuitButton

func _ready() -> void:
	var has_save := GameManager.has_save()
	continue_button.disabled = not has_save
	load_game_button.disabled = not has_save

	continue_button.pressed.connect(GameManager.continue_game)
	new_game_button.pressed.connect(GameManager.new_game)
	load_game_button.pressed.connect(GameManager.continue_game)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(GameManager.quit_game)

func _on_settings_pressed() -> void:
	print("Settings pressed - settings screen comes next")
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")  # use your real path
