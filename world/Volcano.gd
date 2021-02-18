extends Node2D

const CAMERA_TILT = 60

onready var camera = $Player/Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	camera.position.y -= CAMERA_TILT
	camera.limit_right = 416
	camera.limit_left = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
