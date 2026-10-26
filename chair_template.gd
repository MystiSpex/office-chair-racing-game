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
	
	velocity = direction()
	
	if(Input.is_action_pressed("forward")):
		velocity = movement_speed * Vector3.FORWARD.rotated(Vector3.UP,yaw)
	if(Input.is_action_just_pressed("back")):
		velocity = movement_speed * Vector3.BACK.rotated(Vector3.UP,yaw)
	if(Input.is_action_pressed("left")):
		velocity = movement_speed * Vector3.LEFT.rotated(Vector3.UP,yaw)
	if(Input.is_action_pressed("right")):
		velocity = movement_speed * Vector3.RIGHT.rotated(Vector3.UP,yaw)
	
	if(velocity != Vector3.ZERO):
		velocity.x = lerpf(velocity.x, 0, 0.05)
		velocity.z = lerpf(velocity.z, 0, 0.05)
		pass
	
	move_and_slide()
	pass
	
func direction() -> Vector3:
	return Vector3.ZERO
