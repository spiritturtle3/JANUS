extends CanvasLayer

@onready var instruction_panel: Panel = $InstructionPanel
@onready var instruction_text: Label = $InstructionPanel/InstructionText

enum TutorialStep {
	WALK,
	OPEN_CAMERA,
	TAKE_PHOTO,
	CONFIRM_PHOTO,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WALK
var player_has_moved := false


func _ready() -> void:
	add_to_group("tutorial_ui")
	instruction_panel.show()
	instruction_text.text = "W A S D  //  MOVE"


func _process(_delta: float) -> void:
	match current_step:
		TutorialStep.WALK:
			if (
				Input.is_action_pressed("up")
				or Input.is_action_pressed("down")
				or Input.is_action_pressed("left")
				or Input.is_action_pressed("right")
			):
				player_has_moved = true

			if player_has_moved:
				current_step = TutorialStep.OPEN_CAMERA
				instruction_text.text = "E  //  OPEN CAMERA"

		TutorialStep.OPEN_CAMERA:
			if Input.is_action_just_pressed("camera_mode"):
				current_step = TutorialStep.TAKE_PHOTO
				instruction_text.text = "LEFT CLICK  //  TAKE PHOTO"

		TutorialStep.CONFIRM_PHOTO:
			if Input.is_action_just_pressed("ui_accept"):
				current_step = TutorialStep.COMPLETE
				instruction_panel.hide()


func on_photo_preview_opened() -> void:
	if current_step == TutorialStep.TAKE_PHOTO:
		current_step = TutorialStep.CONFIRM_PHOTO
		instruction_text.text = "ENTER  //  CONFIRM"
