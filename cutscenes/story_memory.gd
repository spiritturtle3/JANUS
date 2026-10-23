extends Node

var choices: Dictionary = {}  # level number -> choice index (0 = left, 1 = right)


func set_choice(level: int, index: int) -> void:
	choices[level] = index


func get_choice(level: int) -> int:
	return choices.get(level, -1)


func reset() -> void:
	choices.clear()
