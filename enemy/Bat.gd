extends Actor


onready var animation_player = $AnimationPlayer
onready var blink_player = $BlinkPlayer


func _ready():
	animation_player.play("flying")


func stagger():
	blink_player.blink(1)
	

#this is automatically called on bat death
var red = preload("res://red/Red.tscn")
func die():
	call_deferred("splatter")
	queue_free()
	
func splatter():
	for i in range(0,10):
		var blood = red.instance()
		get_parent().add_child(blood)
			
		blood.global_position = Vector2(self.global_position.x + rand_range(-20,20),
		self.global_position.y + rand_range(-20,20))

