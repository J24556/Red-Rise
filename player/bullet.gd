class_name Bullet
extends Area2D

var damage = 0
var velocity = Vector2.ZERO


func set_up(vec, dam, xval = 1):
	velocity = vec
	damage = dam
	$Sprite.scale.x = xval


func _physics_process(delta):
	position += velocity * delta


func disable():
	queue_free()


func _on_Bullet_area_entered(area):
	disable()


func _on_Bullet_body_entered(body):
	if body.has_method("damage"):
		body.call("damage", damage)
	disable()
