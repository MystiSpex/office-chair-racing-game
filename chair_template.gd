extends CharacterBody3D

@onready var mesh = $MeshInstance3D
@onready var camera = $Marker3D
@onready var colision_shape = $CollisionShape3D

@export var movement_speed: float = 10
@export var acceleration: float = 10
@export var deceleration: float = 10
@export var rotation_speed: float = 5.0

var yaw

func _ready() -> void:
	pass

func _init() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	yaw = rotation.y
	
	if(Input.is_action_pressed("ui_up")):
		velocity = movement_speed * Vector3.FORWARD.rotated(Vector3.UP,yaw)
	if(Input.is_action_just_pressed("ui_down")):
		velocity = movement_speed * Vector3.BACK.rotated(Vector3.UP,yaw)
	if(Input.is_action_pressed("ui_left")):
		velocity = movement_speed * Vector3.LEFT.rotated(Vector3.UP,yaw)
	if(Input.is_action_pressed("ui_right")):
		velocity = movement_speed * Vector3.RIGHT.rotated(Vector3.UP,yaw)
	
	move_and_slide()
	pass
	
