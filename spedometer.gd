extends Label

@onready var player: CharacterBody3D = get_parent().get_parent() as CharacterBody3D

func _process(_delta: float) -> void:
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	text = "Speed: %.1f" % speed
