extends CharacterBody3D
class_name ChairPlayer

@onready var mesh = $MeshInstance3D
@onready var camera = $Marker3D
@onready var collision_shape = $CollisionShape3D
@onready var collision_sound = $CollisionPlayer
@onready var bg_music = $BGMusic

@export_category("Movement")
@export var movement_speed: float = 10
@export var acceleration: float = 10
@export var deceleration: float = 10
@export var rotation_speed: float = 5.0

@export_category("Sensitivity")
@export var pitch: float = 0.0
@export var sensitivity: float = 0.005

var yaw: float
var lap_count: int
var was_colliding: bool

signal lap_count_changed(lap_count: int)

func _ready() -> void:
	camera.rotation.x = pitch
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	bg_music.play()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		pitch = clamp(pitch - event.relative.y * sensitivity, -PI / 2 + 0.01, PI / 2 - 0.01)
		camera.rotation.x = pitch

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

	var is_colliding := get_slide_collision_count() > 0
	if is_colliding and not was_colliding and not collision_sound.playing:
		collision_sound.play()
	was_colliding = is_colliding
	
func direction() -> Vector3:
	return Vector3.ZERO

func _on_checkpoint_reached(checkpoint_number: int) -> void:
	if checkpoint_number != 1:
		return

	lap_count += 1
	lap_count_changed.emit(lap_count)
