extends StaticBody2D

const HANG_TIME = .5

export (bool) var crumbling = false

onready var animation_player = $AnimationPlayer
onready var timer = $Timer

var triggered = false

func stand_on():
	if crumbling and not triggered:
		triggered = true
		animation_player.play("crack")
		timer.start(HANG_TIME)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "crumble":
		queue_free()


func _on_Timer_timeout():
	#the crumble animation disables the platform's collider a little bit after starting
	animation_player.play("crumble")
