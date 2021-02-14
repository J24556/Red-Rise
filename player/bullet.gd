class_name Bullet
extends Area2D

var disabled = false
var velocity = Vector2.ZERO

func set_velocity(vec):
	velocity = vec

func _physics_process(delta):
	position += velocity * delta

func disable():
	queue_free()
	#if disabled:
	#	return

	#($AnimationPlayer as AnimationPlayer).play("shutdown")
	#disabled = true


func _on_Bullet_area_entered(area):
	disable()


func _on_Bullet_body_entered(body):
	disable()
