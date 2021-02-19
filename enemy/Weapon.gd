extends Area2D

export (int) var damage = 1


onready var coll = get_coll()


func get_coll():
	for n in get_children():
		if n is CollisionObject2D:
			return n
	return null


func _on_Weapon_body_entered(body):
	if body.has_method("damage"):
		body.call_deferred("damage", damage)
