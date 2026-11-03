extends Area3D
class_name Checkpoint

signal lap_reached

func _on_body_entered(_body: Node3D) -> void:
	if _body is CharacterBody3D:
		lap_reached.emit()
