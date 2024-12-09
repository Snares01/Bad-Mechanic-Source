extends Tower

const BASE_RANGE := 60.0
const BASE_RELOAD := 0.7
const MINI_BASE_DAMAGE := 12.0
const MINI_SPREAD := 0.16 # Inaccuracy in radians
const BIG_BASE_DAMAGE := 24.0

export var mini_bullet : Resource
export var big_bullet : Resource

onready var animator = $Animator
onready var timer = $Timer

var reload_time := BASE_RELOAD
var damage_multiplier := 1.0


func _ready():
	animator.play("Idle")

func update_stats(): # Max 10
	reload_time = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.05))
	damage_multiplier = 1.0 + (TowerDict.stats[id]["Damage"] * 0.1)
	sight_range = BASE_RANGE


func _physics_process(delta):
	if active and animator.current_animation == "Idle" and timer.is_stopped():
		_start_shooting_anim()


func shoot(pos : Vector2, angle : float, mini := false):
	var instance : Bullet
	if mini:
		instance = mini_bullet.instance()
		get_parent().add_child(instance)
		instance.create_bullet(position + pos, deg2rad(angle), 25.0,
		MINI_BASE_DAMAGE * damage_multiplier, MINI_SPREAD)
	else:
		instance = big_bullet.instance()
		get_parent().add_child(instance)
		instance.create_bullet(position + pos, deg2rad(angle), 32.0,
		BIG_BASE_DAMAGE * damage_multiplier, 0.0, 10.0, 2.0)


func _on_animation_finished(anim_name):
	timer.start(reload_time)
	animator.play("Idle")


func _on_Timer_timeout():
	if active:
		_start_shooting_anim()


func _start_shooting_anim():
	var rand := randf()
	if rand < 0.25:
		animator.play("Shoot Down")
	elif rand < 0.5:
		animator.play("Shoot Left")
	elif rand < 0.75:
		animator.play("Shoot Right")
	else:
		animator.play("Shoot Up")
