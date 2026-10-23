extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("idle")

func _process(_delta: float) -> void:
	var moving := (
		Input.is_action_pressed("up")
		or Input.is_action_pressed("down")
		or Input.is_action_pressed("left")
		or Input.is_action_pressed("right")
	)

	# Flip when moving left, including diagonally up-left/down-left.
	if Input.is_action_pressed("left"):
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		sprite.flip_h = false

	# Switch animations.
	var target_animation := "move" if moving else "idle"

	if sprite.animation != target_animation:
		sprite.play(target_animation)
