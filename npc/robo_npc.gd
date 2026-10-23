extends CharacterBody2D

@export var speed: float = 35.0
@export var wait_before_moving: float = 3.0
@export var sludge_stop_x: float = 225.0

var elapsed_time: float = 0.0
var has_stopped: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	velocity = Vector2.ZERO
	sprite.play("up")
	sprite.set_frame_and_progress(1, 0.0)
	sprite.pause()


func _physics_process(delta: float) -> void:
	if has_stopped:
		velocity = Vector2.ZERO
		return

	elapsed_time += delta

	# Stand still in frame 1 of the up animation.
	if elapsed_time < wait_before_moving:
		velocity = Vector2.ZERO
		return

	# Walk right toward the sludge.
	if global_position.x >= sludge_stop_x:
		global_position.x = sludge_stop_x
		velocity = Vector2.ZERO
		has_stopped = true
		sprite.set_frame_and_progress(1, 0.0)
		sprite.pause()
		return

	velocity.x = speed
	velocity.y = 0.0

	if sprite.animation != "right" or not sprite.is_playing():
		sprite.play("right")

	move_and_slide()
