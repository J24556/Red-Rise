extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("crumble")

func _physics_process(_delta):
	animation_player.play("crumble")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
