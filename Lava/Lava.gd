extends Area2D

const SPEED = 2
const BUBBLE_TIME = .1
const EDGE = 5

onready var LavaBubble = preload("res://Lava/LavaBubble.tscn")

onready var timer = $Timer

func _ready():
	randomize()
	timer.start(BUBBLE_TIME)

func _physics_process(delta):
	position.y += -1 * SPEED * delta


func spawn_bubble():
	var bubble = LavaBubble.instance()
	bubble.position = Vector2(rand_range(0 - EDGE, 400 - 16 + EDGE), -15)
	add_child(bubble)


func _on_Timer_timeout():
	spawn_bubble()
