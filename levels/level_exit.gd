extends Area2D

@export_file("*.tscn") var next_scene: String
@export var starts_locked: bool = false
@export var blocker: StaticBody2D

var unlocked: bool = true


func _ready() -> void:
	unlocked = not starts_locked
	body_entered.connect(_on_body_entered)
	_set_blocker(not unlocked)


func unlock() -> void:
	unlocked = true
	_set_blocker(false)
	# If the player is already standing in the box, body_entered won't fire again
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _set_blocker(active: bool) -> void:
	if blocker == null:
		return
	for child in blocker.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not active)


func _on_body_entered(body: Node2D) -> void:
	if unlocked and body.name == "Player":
		SceneTransition.go_to.call_deferred(next_scene)
