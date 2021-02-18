class_name Enemy
extends RigidBody2D

const WALK_SPEED = 50
const SHOT_SPEED = 15
const VISION_LENGTH = 100
var SHOT_DELAY = 0.3

enum State {
	WALKING,
	DYING,
}

var state = State.WALKING

var direction = -1
var anim = ""

var Bullet_gd = preload("res://player/player_bullet.gd")
var Bullet = preload("res://player/PlayerBullet.tscn") #change to player damaging tscn
onready var shot_delay_timer = $ShotDelay
onready var rc_left = $RaycastLeft
onready var rc_right = $RaycastRight
onready var rc_shoot = $RaycastGun

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
			bi.set_velocity(rc_shoot.get_cast_to() * -SHOT_SPEED)

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
