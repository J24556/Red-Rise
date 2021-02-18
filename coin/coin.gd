class_name Coin
extends Area2D

var taken = false


func _on_body_enter(body):
	if not taken and body is Player:
		(body as Player).SET_ANGRY(true,self.get_instance_id())

func _on_body_exited(body):
	if body is Player:
		(body as Player).SET_ANGRY(false,self.get_instance_id())
