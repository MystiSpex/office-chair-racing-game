extends Node
class_name CPUContextSteering

@export var target: Node3D
@export_range(8, 64, 1) var direction_count: int = 16
@export_range(1.0, 30.0, 0.5) var sensor_distance: float = 6.0
@export_range(0.1, 3.0, 0.1) var sensor_height: float = 0.75
@export_range(0.1, 5.0, 0.1) var avoidance_weight: float = 2.0
@export_range(0.1, 3.0, 0.1) var target_weight: float = 1.0
@export_flags_3d_physics var obstacle_collision_mask: int = 3

var racer: CharacterBody3D

func _ready() -> void:
	racer = get_parent() as CharacterBody3D
	if racer == null:
		push_error("CPUContextSteering must be a child of a CharacterBody3D.")

func get_steering_direction() -> Vector3:
	if racer == null or not is_instance_valid(target):
		return Vector3.ZERO

	var target_direction := target.global_position - racer.global_position
	target_direction.y = 0.0
	if target_direction.is_zero_approx():
		return Vector3.ZERO
	target_direction = target_direction.normalized()

	var space_state := racer.get_world_3d().direct_space_state
	var ray_origin := racer.global_position + racer.up_direction * sensor_height
	var excluded: Array[RID] = [racer.get_rid()]
	var best_direction := Vector3.ZERO
	var best_score := -INF

	for index in direction_count:
		var angle := TAU * float(index) / float(direction_count)
		var local_direction := Vector3(sin(angle), 0.0, -cos(angle))
		var world_direction := racer.global_basis.orthonormalized() * local_direction
		world_direction.y = 0.0
		world_direction = world_direction.normalized()

		var ray_end := ray_origin + world_direction * sensor_distance
		var query := PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end,
			obstacle_collision_mask,
			excluded
		)
		query.collide_with_areas = false
		var hit: Dictionary = space_state.intersect_ray(query)

		var score := world_direction.dot(target_direction) * target_weight
		if not hit.is_empty():
			var hit_position: Vector3 = hit["position"]
			var hit_distance := ray_origin.distance_to(hit_position)
			var proximity := 1.0 - clampf(hit_distance / sensor_distance, 0.0, 1.0)
			score -= proximity * avoidance_weight

		if score > best_score:
			best_score = score
			best_direction = world_direction

	return best_direction
