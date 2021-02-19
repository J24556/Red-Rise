extends Actor


onready var animation_player = $AnimationPlayer
onready var blink_player = $BlinkPlayer


func _ready():
	animation_player.play("flying")


func stagger():
	blink_player.blink(1)
	

#this is automatically called on bat death
func die():
	pass
