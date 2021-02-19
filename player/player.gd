class_name Player
extends Actor

const RUN_SPEED = 150
const JUMP_SPEED = 350
const SPEED = Vector2(RUN_SPEED, JUMP_SPEED)
const SHOT_DELAY = 0.3
const MIN_SHOT_DELAY = 0.05
const RED_SPEED_MULT = 2.5
const RED_SHOT_DELAY_MULT = .01
const FLOOR_DETECT_DISTANCE = 20.0
const MAX_RED = 20

const DAMAGE = 1


const SHOT_SPEED = 700
const GUN_PUT_AWAY_TIME = 0.6

var bullet = preload("res://player/PlayerBullet.tscn")
var sprite_no_arm = preload("res://player/characteronearm.png")
var sprite_chad_when_stock_go_down = preload("res://player/chad_in_the_red.png")
var sprite_with_arm = preload("res://player/charactertwoarms.png")

const RED_JUMP_BONUS = 10
var redness = 0
var red_touch = 0

const MAX_AMMO = 14
var ammo = MAX_AMMO

onready var platform_detector = $PlatformDetector
onready var platform_detector2 = $PlatformDetector2
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var sprite_smoke = $Sprite/ArmPivot/GunArm/Smoke
onready var arm_pivot = $Sprite/ArmPivot
onready var gun_arm = $Sprite/ArmPivot/GunArm
onready var bullet_shoot = $Sprite/ArmPivot/GunArm/BulletShoot
onready var shot_delay_timer = $ShotDelayTimer
onready var shoot_anim_timer = $ShootAnimTimer
onready var sound_jump = $SoundJump
onready var sound_shoot = $SoundShoot
onready var light = $Light2D



func die():
	get_tree().reload_current_scene()


func _physics_process(delta):

	#GET INPUT AND STATUS
	var mouse_pos = get_global_mouse_position()
	var mouse_dir = global_position.direction_to(mouse_pos)
	var mouse_arm_dir = arm_pivot.global_position.direction_to(mouse_pos)
	var mouse_arm_angle = rad2deg(arm_pivot.global_position.angle_to_point(mouse_pos))
	var move_dir = get_move_dir()
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	
	var new_speed = Vector2(SPEED.x + (redness * RED_SPEED_MULT), SPEED.y + redness * RED_JUMP_BONUS)
	
	_velocity = calculate_move_velocity(_velocity, move_dir, new_speed, is_jump_interrupted)

	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if move_dir.y == 0.0 else Vector2.ZERO
	var is_on_platform = platform_detector.is_colliding() or platform_detector2.is_colliding()

	var shoot_anim = not shoot_anim_timer.is_stopped()

	$ammo.set_text(String(ammo))
	var is_shooting = false
	if Input.is_action_pressed("shoot"):
		shoot_anim_timer.start(GUN_PUT_AWAY_TIME)
		if shot_delay_timer.is_stopped():
			is_shooting = true

	#ACT

	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, is_on_platform, 4, 1.396, false
	)
	
	if is_on_floor():
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.has_method("stand_on"):
				collision.collider.stand_on()

	if shoot_anim:
		sprite.texture = sprite_no_arm
		gun_arm.visible = true
		$ammo.visible = true
		if mouse_dir.x != 0:
			sprite.scale.x = 1 if mouse_dir.x > 0 else -1
	else:
		sprite.texture = sprite_with_arm
		gun_arm.visible = false
		$ammo.visible = false
		ammo = MAX_AMMO #weapon is reloaded when putaway
		if move_dir.x != 0:
			sprite.scale.x = 1 if move_dir.x > 0 else -1

	if sprite.scale.x == 1:
		arm_pivot.rotation_degrees = mouse_arm_angle + 180
	else:
		arm_pivot.rotation_degrees = (-1 * mouse_arm_angle)

	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

	if is_shooting:
		shoot_bullet(mouse_arm_dir)
		var new_delay = max(SHOT_DELAY - (redness * RED_SHOT_DELAY_MULT), MIN_SHOT_DELAY)
		shot_delay_timer.start(new_delay)


func get_move_dir():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)


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
		velocity.y *= 0.6
	return velocity


func shoot_bullet(dir):
	if ammo <= 0:
		return	
	ammo-=1

	var bi = bullet.instance()

	bi.global_position = bullet_shoot.global_position
	get_parent().add_child(bi)

	bi.set_up(dir * SHOT_SPEED, DAMAGE)

	sprite_smoke.restart()
	sound_shoot.play()


func get_new_animation():
	var animation_new = ""
	if is_on_floor():
		animation_new = "run" if abs(_velocity.x) > 0.1 else "idle"
	else:
		animation_new = "falling" if _velocity.y > 0 else "jumping"
	return animation_new




func _on_RedTimer_timeout():
	if red_touch > 0:
		redness = min(redness + 1.4, MAX_RED)
	else:
		redness = max(redness - .7, 0)
	
	if redness > 0:
		sprite.modulate = Color(1, 1 - (1.0 * redness / MAX_RED), 1 - (1.0 * redness / MAX_RED), 1)
	else:
		sprite.modulate = Color.white
		
	light.energy = redness / 16
