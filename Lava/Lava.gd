extends Area2D

const SPEED = 30
const BUBBLE_TIME = .1
const EDGE = 5

onready var LavaBubble = preload("res://Lava/LavaBubble.tscn")
onready var player = preload("res://player/Player.tscn")
onready var timer = $Timer
onready var pool = $Pool

func _ready():
	randomize()
	timer.start(BUBBLE_TIME)

func _physics_process(delta):
	position.y += -1 * SPEED * delta


func spawn_bubble():
	var bubble = LavaBubble.instance()
	bubble.position = Vector2(rand_range(0 - EDGE, 400 - 16 + EDGE), -15)
	pool.add_child(bubble)


func _on_Timer_timeout():
	spawn_bubble()


func _on_Lava_body_entered(body):
	if body.has_method("damage"):
		body.call("damage", 10)
