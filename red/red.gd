class_name Red
extends Area2D


func _on_body_enter(body):
	if body is Player:
		(body as Player).red_touch += 1


func _on_body_exited(body):
	if body is Player:
		(body as Player).red_touch -= 1
