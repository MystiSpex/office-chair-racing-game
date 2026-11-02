extends Button

func _on_pressed() -> void:
	var error := get_tree().change_scene_to_file("res://main.tscn")
	if error != OK:
		push_error("Could not open main.tscn: " + error_string(error))
