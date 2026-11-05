extends PanelContainer

@onready var score_list: VBoxContainer = $VBoxContainer/Scores

func _ready() -> void:
	ScoreStore.scores_changed.connect(set_scoreboard)
	set_scoreboard()

func set_scoreboard() -> void:
	for child in score_list.get_children():
		child.queue_free()

	if ScoreStore.scores.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No scores yet"
		empty_label.add_theme_font_size_override("font_size", 20)
		score_list.add_child(empty_label)
		return

	for index in range(ScoreStore.scores.size()):
		var entry: Dictionary = ScoreStore.scores[index]
		var score_label := Label.new()
		score_label.add_theme_font_size_override("font_size", 20)
		score_label.text = "%d. %s - %s" % [
			index + 1,
			entry["name"],
			_format_time(float(entry["time"]))
		]
		score_list.add_child(score_label)

func _format_time(time_seconds: float) -> String:
	var total_milliseconds := int(round(time_seconds * 1000.0))
	var minutes := int(total_milliseconds / 60000.0)
	var seconds := int(total_milliseconds / 1000.0) % 60
	var milliseconds := total_milliseconds % 1000
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
