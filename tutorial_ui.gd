extends CanvasLayer  # change this to match TutorialUI's actual node type (see note below)

@export var display_time: float = 3.0

func _ready() -> void:
	# Keep running even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true

	# Optional: freeze the game while the tutorial is showing
	get_tree().paused = true

	await get_tree().create_timer(display_time, true, false, true).timeout

	get_tree().paused = false
	queue_free()  # removes the tutorial from the screen completely
