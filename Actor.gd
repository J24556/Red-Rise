class_name Actor
extends KinematicBody2D


const FLOOR_NORMAL = Vector2.UP


export (int) var max_health = 10
export (bool) var falls = true


onready var gravity = ProjectSettings.get("physics/2d/default_gravity")


onready var health = max_health
 

var _velocity = Vector2.ZERO


func _physics_process(delta):
	if falls:
		_velocity.y += gravity * delta


func damage(val):
	health -= val
	if health <= 0:
		if has_method("die"):
			call("die")
		else:
			queue_free()
	elif has_method("stagger"):
		call("stagger")
