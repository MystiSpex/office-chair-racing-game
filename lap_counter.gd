extends Label

@onready var player: ChairPlayer = get_node("../..") as ChairPlayer

func _ready() -> void:
	update_lap_count()
	player.lap_count_changed.connect(_on_lap_count_changed)

func update_lap_count() -> void:
	text = "Lap: %d" % (player.lap_count + 1)

func _on_lap_count_changed(_lap_count: int) -> void:
	update_lap_count()
