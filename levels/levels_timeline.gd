extends Node

@export var level_id: String = "level_2"

# time = seconds of gameplay since the level started
const EVENTS := {
	"level_2": [],
	"level_3": [
		{"time": 1.5, "type": "monologue", "text": "That woman must be the one who the editor was talking about.", "duration": 5.0},
	],
	"level_4": [
		{"time": 1.5, "type": "notify", "text": "Take a picture of the building in front of you.", "duration": 6.0},
	],
}

var elapsed := 0.0
var queue: Array = []


func _ready() -> void:
	queue = EVENTS.get(level_id, []).duplicate()
	queue.sort_custom(func(a, b): return a["time"] < b["time"])


func _process(delta: float) -> void:
	elapsed += delta
	while not queue.is_empty() and elapsed >= queue[0]["time"]:
		_fire(queue.pop_front())


func _fire(e: Dictionary) -> void:
	var audio: AudioStream = load(e["audio"]) if e.has("audio") else null
	match e["type"]:
		"monologue":
			Narrator.monologue(e["text"], e.get("duration", 4.0), audio)
		"notify":
			Narrator.notify(e["text"], e.get("duration", 3.0))
