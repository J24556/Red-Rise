class_name Player
extends Actor

const FLOOR_DETECT_DISTANCE = 20.0
const SHOT_DELAY = 0.3
const SHOT_SPEED = 400

var Bullet = preload("res://player/PlayerBullet.tscn")

onready var platform_detector = $PlatformDetector
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var sprite_smoke = sprite.get_node(@"Smoke")
onready var bullet_shoot = $BulletShoot
onready var shot_delay_timer = $ShotDelayTimer
onready var sound_jump = $SoundJump
onready var sound_shoot = $SoundShoot


func _physics_process(_delta):
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	var move_dir = get_move_dir()

	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, move_dir, speed, is_jump_interrupted)

	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if move_dir.y == 0.0 else Vector2.ZERO
	var is_on_platform = platform_detector.is_colliding()
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)
	
	if is_on_platform:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.has_method("stand_on"):
				collision.collider.stand_on()

	# When the character’s move_dir changes, we want to to scale the Sprite accordingly to flip it.
	# This will make Robi face left or right depending on the move_dir you move.
	if mouse_dir.x != 0:
		sprite.scale.x = 1 if mouse_dir.x > 0 else -1

	# We use the sprite's scale to store Robi’s look move_dir which allows us to shoot
	# bullets forward.
	# There are many situations like these where you can reuse existing properties instead of
	# creating new variables.
	var is_shooting = false
	if Input.is_action_pressed("shoot"):
		is_shooting = true
		if shot_delay_timer.is_stopped():
			shot_bullet(mouse_dir)
			shot_delay_timer.start(SHOT_DELAY)


	var animation = get_new_animation(is_shooting)
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_move_dir():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)


# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		move_dir,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * move_dir.x
	if move_dir.y != 0.0:
		velocity.y = speed.y * move_dir.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity

func shot_bullet(dir):
	var bi = Bullet.instance()
	var pos = position + (dir * bullet_shoot.position.x) 

	bi.position = pos
	get_parent().add_child(bi)

	bi.set_velocity(dir * SHOT_SPEED)

	sprite_smoke.restart()
	sound_shoot.play()

func get_new_animation(is_shooting = false):
	var animation_new = ""
	if is_on_floor():
		animation_new = "run" if abs(_velocity.x) > 0.1 else "idle"
	else:
		animation_new = "falling" if _velocity.y > 0 else "jumping"
	return animation_new
