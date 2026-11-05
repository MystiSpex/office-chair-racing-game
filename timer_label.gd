extends Control

# Nodes
@onready var time_label: Label = $TimeLabel

var time_shown

# Stopwatch state variables
var time_elapsed: float = 0.0
var is_running: bool = false

func _ready() -> void:
	# Start the stopwatch automatically when the scene loads
	start_stopwatch()

func _process(delta: float) -> void:
	if is_running:
		time_elapsed += delta
		update_ui()

# Formats the float time into MM:SS.mmm
func update_ui() -> void:
	var minutes: int = int(time_elapsed / 60)
	var seconds: int = int(time_elapsed) % 60
	var milliseconds: int = int((time_elapsed - int(time_elapsed)) * 1000)
	
	# %02d pads numbers with a leading zero if they are single digits
	# %03d pads milliseconds to 3 digits
	time_shown = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
	time_label.text = time_shown

# Public functions to control the stopwatch from other scripts
func start_stopwatch() -> void:
	is_running = true

func pause_stopwatch() -> void:
	is_running = false

func reset_stopwatch() -> void:
	time_elapsed = 0.0
	update_ui()
