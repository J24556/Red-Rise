extends AnimatedSprite


func _ready():
	playing = true


func _on_LavaBubble_animation_finished():
	queue_free()
