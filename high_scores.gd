extends Node
class_name HighScores

const SAVE_PATH := "user://high_scores.save"
const MAX_SCORES := 10

var scores: Array[Dictionary] = []

signal scores_changed

func _ready() -> void:
	_load_scores()

func record_score(player_name: String, time_seconds: float) -> void:
	if not is_finite(time_seconds) or time_seconds < 0.0:
		push_error("Cannot record an invalid race time.")
		return

	scores.append({"name": player_name, "time": time_seconds})
	_sort_and_limit()
	_save_scores()
	scores_changed.emit()

func _sort_and_limit() -> void:
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["time"]) < float(b["time"])
	)
	if scores.size() > MAX_SCORES:
		scores.resize(MAX_SCORES)

func _load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not read high scores: " + error_string(FileAccess.get_open_error()))
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		push_error("Could not parse high scores: " + json.get_error_message())
		return
	if not (json.data is Array):
		push_error("High score save data must be an array.")
		return

	for entry in json.data:
		if not (entry is Dictionary):
			push_error("High score entry must be an object.")
			return
		var raw_name: Variant = entry.get("name")
		var raw_time: Variant = entry.get("time")
		if not (raw_name is String) or (typeof(raw_time) != TYPE_FLOAT and typeof(raw_time) != TYPE_INT):
			push_error("High score entry has an invalid name or time.")
			return
		var time_seconds := float(raw_time)
		if not is_finite(time_seconds) or time_seconds < 0.0:
			push_error("High score entry has an invalid time.")
			return
		scores.append({"name": raw_name, "time": time_seconds})

	_sort_and_limit()

func _save_scores() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not save high scores: " + error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(scores))
