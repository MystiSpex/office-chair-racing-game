extends Area3D
class_name Checkpoint

@export_range(1, 4) var checkpoint_number: int = 1

signal checkpoint_reached(checkpoint_number: int)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		checkpoint_reached.emit(checkpoint_number)
