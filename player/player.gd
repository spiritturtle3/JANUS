extends CharacterBody2D

@export var speed: float = 120.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footsteps: AudioStreamPlayer2D = $Footsteps

var last_direction: Vector2 = Vector2.DOWN
var camera_mode_active: bool = false


func _ready() -> void:
	if footsteps.stream is AudioStreamMP3:
		(footsteps.stream as AudioStreamMP3).loop = true


func _physics_process(_delta: float) -> void:
	if camera_mode_active:
		velocity = Vector2.ZERO
		update_idle_animation()
		set_footsteps(false)
		return

	var input_direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	if input_direction != Vector2.ZERO:
		velocity = input_direction * speed
		last_direction = input_direction.normalized()
		update_animation(input_direction)
	else:
		velocity = Vector2.ZERO
		update_idle_animation()

	move_and_slide()
	set_footsteps(velocity.length() > 5.0)


func set_footsteps(walking: bool) -> void:
	if walking and not footsteps.playing:
		footsteps.play()
	elif not walking and footsteps.playing:
		footsteps.stop()


func update_animation(direction: Vector2) -> void:
	if direction.x != 0:
		sprite.play("left" if direction.x < 0 else "right")
		sprite.flip_h = direction.x > 0
	elif direction.y < 0:
		sprite.play("up")
		sprite.flip_h = false
	else:
		sprite.play("down")
		sprite.flip_h = false


func update_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		sprite.play("idle_left" if last_direction.x < 0 else "idle_right")
		sprite.flip_h = last_direction.x > 0
	elif last_direction.y < 0:
		sprite.play("idle_up")
		sprite.flip_h = false
	else:
		sprite.play("idle_down")
		sprite.flip_h = false


func set_camera_idle() -> void:
	camera_mode_active = true
	velocity = Vector2.ZERO
	update_idle_animation()
	set_footsteps(false)


func exit_camera_mode() -> void:
	camera_mode_active = false
	velocity = Vector2.ZERO
