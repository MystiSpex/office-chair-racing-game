extends CharacterBody3D

@export_range(1, 4, 1) var starting_checkpoint_number: int = 1
@export_range(1.0, 30.0, 0.5) var cruising_speed: float = 10.0
@export_range(0.1, 5.0, 0.1) var turn_speed: float = 2.5
@export_range(1.0, 30.0, 0.5) var acceleration: float = 12.0

@onready var context_steering: CPUContextSteering = $ContextSteering

var checkpoints_by_number: Dictionary = {}
var next_checkpoint_number: int
var last_checkpoint_number: int

func _ready() -> void:
	next_checkpoint_number = starting_checkpoint_number
	_load_checkpoint_route()

func _physics_process(delta: float) -> void:
	var target := _get_target_checkpoint()
	if target == null:
		velocity.x = move_toward(velocity.x, 0.0, cruising_speed * delta)
		velocity.z = move_toward(velocity.z, 0.0, cruising_speed * delta)
		move_and_slide()
		return

	context_steering.target = target
	var target_direction := target.global_position - global_position
	target_direction.y = 0.0
	target_direction = target_direction.normalized()

	var avoidance_direction := context_steering.get_steering_direction()
	var steering_direction := target_direction
	if not avoidance_direction.is_zero_approx() and avoidance_direction.dot(target_direction) > 0.0:
		steering_direction = (target_direction + avoidance_direction * 0.25).normalized()

	var desired_yaw := atan2(-steering_direction.x, -steering_direction.z)
	var heading_error := absf(wrapf(desired_yaw - global_rotation.y, -PI, PI))
	var target_speed := lerpf(cruising_speed, cruising_speed * 0.5, clampf(heading_error / PI, 0.0, 1.0))
	global_rotation.y = rotate_toward(global_rotation.y, desired_yaw, turn_speed * delta)

	var forward := -global_basis.z
	velocity.x = move_toward(velocity.x, forward.x * target_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, forward.z * target_speed, acceleration * delta)
	move_and_slide()

func _get_target_checkpoint() -> Checkpoint:
	if not checkpoints_by_number.has(next_checkpoint_number):
		return null
	return checkpoints_by_number[next_checkpoint_number] as Checkpoint

func _on_checkpoint_reached(body: Node3D, checkpoint_number: int) -> void:
	if body != self or checkpoint_number != next_checkpoint_number:
		return
	if last_checkpoint_number == 0:
		return
	next_checkpoint_number = next_checkpoint_number % last_checkpoint_number + 1

func _load_checkpoint_route() -> void:
	var checkpoint_container := get_parent().get_node_or_null("checkpoints")
	if checkpoint_container == null:
		push_error("CPU could not find the checkpoints container.")
		return

	for child in checkpoint_container.get_children():
		if child is Checkpoint:
			var checkpoint := child as Checkpoint
			if checkpoints_by_number.has(checkpoint.checkpoint_number):
				push_error("Duplicate checkpoint number: %d" % checkpoint.checkpoint_number)
				return
			checkpoints_by_number[checkpoint.checkpoint_number] = checkpoint
			last_checkpoint_number = maxi(last_checkpoint_number, checkpoint.checkpoint_number)
			checkpoint.body_checkpoint_reached.connect(_on_checkpoint_reached)

	if last_checkpoint_number == 0:
		push_error("CPU found no numbered checkpoints.")
		return

	for number in range(1, last_checkpoint_number + 1):
		if not checkpoints_by_number.has(number):
			push_error("CPU checkpoint route is missing checkpoint number %d." % number)
			return

	if not checkpoints_by_number.has(starting_checkpoint_number):
		push_error("CPU starting checkpoint number %d does not exist." % starting_checkpoint_number)
