extends CharacterBody3D

@onready var mesh = $MeshInstance3D
@onready var camera = $Marker3D
@onready var colision_shape = $CollisionShape3D

@export_category("Movement")
@export var movement_speed: float = 10
@export var acceleration: float = 10
@export var deceleration: float = 10
@export var rotation_speed: float = 5.0

@export_category("Sensitivity")
@export var pitch: float = 0.5
@export var sensitivity: float = 0.005

var yaw

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		rotate_y(-event.relative.x * sensitivity)        # yaw the body
		pitch = clamp(pitch - event.relative.y * sensitivity, -PI/2 + 0.01, PI/2 - 0.01)         # stop at ±90°
		camera.rotation.x = pitch
		

func _init() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	yaw = rotation.y
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var target_velocity := Vector3.ZERO
	if input_dir != Vector2.ZERO:
		var move_dir := Vector3(input_dir.x, 0.0, input_dir.y).rotated(Vector3.UP, yaw)
		target_velocity = move_dir.normalized() * movement_speed

	var speed_change := acceleration if target_velocity != Vector3.ZERO else deceleration
	velocity.x = move_toward(velocity.x, target_velocity.x, speed_change * _delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, speed_change * _delta)
	move_and_slide()
	pass
	
func direction() -> Vector3:
	return Vector3.ZERO
