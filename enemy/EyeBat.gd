extends Bat

const SHOT_DELAY = 1.2
const DAMAGE = 1
const SHOT_SPEED = 50

var bullet = preload("res://enemy/EnemyBullet.tscn")


onready var shoot_timer = $ShootTimer

var player = null

func shoot(dir, rot):

	var bi = bullet.instance()

	bi.global_position = global_position
	bi.global_rotation = rot
	get_parent().add_child(bi)

	bi.set_up(dir * SHOT_SPEED, DAMAGE, .5)


func _on_Looker_body_entered(body):

	player = body
	shoot_timer.start(SHOT_DELAY)


func _on_Looker_body_exited(body):

	player = null


func _on_ShootTimer_timeout():
	if player == null:
		return
	var dir = global_position.direction_to(player.global_position)
	var rot = player.global_position.angle_to(global_position)
	call_deferred("shoot", dir, rot)
	shoot_timer.start(SHOT_DELAY)


