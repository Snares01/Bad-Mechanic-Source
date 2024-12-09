extends Tower

const BASE_RELOAD := 1.4
const BASE_STUN := 12.0
const BASE_EXPLOSION_NUM := 17 # Number of particles per explosion
const BASE_EXPLOSION_VELOCITY := 115.0
const BASE_RANGE := 35.0
const AIM_OFFSET := Vector2(0, -7)
const BULLET_LIFE := 0.48
const BULLET_DECAY := 180.0

export var bullet: Resource

onready var animator: AnimationPlayer = $Animator
var reload_speed := BASE_RELOAD
var stun := BASE_STUN
var explosion_num := BASE_EXPLOSION_NUM
var explosion_velocity := BASE_EXPLOSION_VELOCITY
var reloaded := true

func _ready():
	animator.play("idle")

func update_stats():
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.16))
	stun = BASE_STUN + (TowerDict.stats[id]["Stun"] * 0.3)
	explosion_num = round(BASE_EXPLOSION_NUM + (TowerDict.stats[id]["Explosion Size"] * 1.2))
	sight_range = BASE_RANGE

func _process(delta):
	if active and reloaded:
		reloaded = false
		animator.play("shoot")

func shoot():
	for i in explosion_num:
		var collide_dir := Vector2(randf() - 0.5, randf() - 0.5).normalized()
		# TODO: add bias to explosion dir
		var instance: Bullet = bullet.instance()
		get_parent().add_child(instance)
		instance.create_bullet(position + AIM_OFFSET, collide_dir.angle(),
		  explosion_velocity + rand_range(-10, 10), stun, 0, BULLET_LIFE, BULLET_DECAY, Bullet.effect.STUN)


func _on_animation_finished(_anim_name):
	var timer := get_tree().create_timer(reload_speed, false)
	timer.connect("timeout", self, "_reload")
	animator.play("idle")

func _reload():
	reloaded = true
