extends AnimationPlayer


onready var timer = $Timer


var is_blinking = false


func _ready():
	play("normal")


#one blink is 0.15 seconds. consecutive blinks add 0.3 seconds each 
func blink(times = 1):
	if not is_blinking and times > 0:
		is_blinking = true
		play("blink")
		timer.start(.15 + .3 * (times - 1))



func _on_Timer_timeout():
	is_blinking = false
	play("normal")


func is_active():
	return is_blinking
