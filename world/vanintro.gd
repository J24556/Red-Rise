extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/Camera.position = Vector2.ZERO
	$Player/Camera.limit_right = 416
