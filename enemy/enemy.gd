class_name Enemy
extends RigidBody2D

var WALK_SPEED = 50
const SHOT_SPEED = .3
const VISION_LENGTH = 500
var SHOT_DELAY = 1

enum State {
	WALKING,
	DYING,
}

var state = State.WALKING

var direction = -1
var anim = ""


var Bullet_gd = preload("res://player/bullet.gd")
var Bullet = preload("res://enemy/EnemyBullet.tscn") #change to player damaging tscn
onready var shot_delay_timer = $ShotDelay
onready var rc_left = $RaycastLeft
onready var rc_right = $RaycastRight
onready var rc_shoot = $RaycastGun
onready var bullet_pos = $Sprite/BulletShoot
onready var turnTimer = $TurnTimer

const  REACT_TIME = .3
var reacting = false
var red = preload("res://red/Red.tscn")
var health = 3
func damage(amnt):
	
	health-=amnt
	call_deferred("splatter")
	
	reacting = true
	$react.start(REACT_TIME)
	
	if health <= 0:
		$Sprite.visible = false
		$Sprite2.visible = true
		rc_shoot.enabled = false
		$Shape1.set_deferred("disabled", true)
		WALK_SPEED = 0
		gravity_scale = 0
		$Weapon/Shape2.set_deferred("disabled", true)
	else:
		$BlinkPlayer.blink()


func splatter():
	for i in range(0,7):
		var blood = red.instance()
		get_parent().add_child(blood)
			
		blood.global_position = Vector2(self.global_position.x + rand_range(-20,20),
		self.global_position.y + rand_range(-20,20))

var en_bullet = preload("res://enemy/FIBULLET.png")
func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var new_anim = anim

	if state == State.DYING:
		new_anim = "explode"
	elif state == State.WALKING:
		new_anim = "walk"

		var wall_side = 0.0

		for i in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(i)
			var dp = s.get_contact_local_normal(i)

			if cc:
				if cc is Bullet_gd and not cc.disabled:
					# enqueue call
					call_deferred("_bullet_collider", cc, s, dp)
					break

			if dp.x > 0.9:
				wall_side = 1.0
			elif dp.x < -0.9:
				wall_side = -1.0

		if rc_shoot.is_colliding() and shot_delay_timer.is_stopped() and turnTimer.is_stopped():
			shot_delay_timer.start(SHOT_DELAY)
			
			call_deferred("fire_bullet")

			($Sprite as Sprite).scale.x = direction
			

		if $react.is_stopped() and reacting:
			reacting = false
			direction = -direction
			($Sprite as Sprite).scale.x = direction
		if wall_side != 0 and wall_side != direction:
			direction = -direction
			($Sprite as Sprite).scale.x = direction
			turnTimer.start(REACT_TIME)
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = direction
			turnTimer.start(REACT_TIME)
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = direction
			turnTimer.start(REACT_TIME)

			
		rc_shoot.set_cast_to(Vector2(direction*-VISION_LENGTH,0))
		lv.x = direction * WALK_SPEED

	if anim != new_anim:
		anim = new_anim
		($AnimationPlayer as AnimationPlayer).play(anim)

	s.set_linear_velocity(lv)


func fire_bullet():
	var bi = Bullet.instance()
	bi.global_position = bullet_pos.global_position
	get_parent().add_child(bi)
	bi.set_up(rc_shoot.get_cast_to() * -SHOT_SPEED , 1, $Sprite.scale.x * .5 )



