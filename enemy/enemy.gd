class_name Enemy
extends RigidBody2D

var WALK_SPEED = 50
const SHOT_SPEED = 2
const VISION_LENGTH = 500
var SHOT_DELAY = 0.3

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

const  REACT_TIME = .3
var reacting = false
var red = preload("res://red/Red.tscn")
var health = 3
func damage(amnt):
	health-=amnt
	
	reacting = true
	$react.start(REACT_TIME)
	
	if health <= 0:
		$Sprite.visible = false
		$Sprite2.visible = true
		rc_shoot.enabled = false
		$Shape1.position.y = 9
		WALK_SPEED = 0
	else:
		for i in range(0,7):
			var blood = red.instance()
			get_parent().add_child(blood)
			randomize()
			
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

		if rc_shoot.is_colliding() and shot_delay_timer.is_stopped():
			shot_delay_timer.start(SHOT_DELAY)
			
			var bi = Bullet.instance()
			bi.global_position = rc_shoot.global_position
			get_parent().add_child(bi)
			bi.set_up(rc_shoot.get_cast_to() * -SHOT_SPEED , 1 )

			($Sprite as Sprite).scale.x = direction
			

		if $react.is_stopped() and reacting:
			reacting = false
			direction = -direction
			($Sprite as Sprite).scale.x = direction
		if wall_side != 0 and wall_side != direction:
			direction = -direction
			($Sprite as Sprite).scale.x = direction
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = direction
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = direction

			
		rc_shoot.set_cast_to(Vector2(direction*-VISION_LENGTH,0))
		lv.x = direction * WALK_SPEED

	if anim != new_anim:
		anim = new_anim
		($AnimationPlayer as AnimationPlayer).play(anim)

	s.set_linear_velocity(lv)


func _die():
	queue_free()


func _pre_explode():
	#make sure nothing collides against this
	$Shape1.queue_free()
	$Shape2.queue_free()
	$Shape3.queue_free()

	# Stay there
	mode = MODE_STATIC
	($SoundExplode as AudioStreamPlayer2D).play()


func _bullet_collider(cc, s, dp):
	mode = MODE_RIGID
	state = State.DYING

	s.set_angular_velocity(sign(dp.x) * 33.0)
	physics_material_override.friction = 1
	cc.disable()
	($SoundHit as AudioStreamPlayer2D).play()
