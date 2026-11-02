extends Area3D
class_name Checkpoint

signal lap_reached

func _on_area_entered(_area: Area3D) -> void:
	emit_signal("lap_reached")
	pass # Replace with function body.
