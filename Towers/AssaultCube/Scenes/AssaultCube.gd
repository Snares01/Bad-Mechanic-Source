extends Tower

const BASE_RELOAD := 1.0 # Time between bursts
const BASE_SMALL_DAMAGE := 34.0
const BASE_BIG_DAMAGE := 100.0
const BASE_RANGE := 50.0
const SMALL_BULLET_SPEED := 50.0
const BIG_BULLET_SPEED := 33.0
const SMALL_BULLET_INACCURACY := 0.2

export var small_bullet : Resource
export var big_bullet : Resource

var reload_speed := BASE_RELOAD
var small_bullet_damage := BASE_SMALL_DAMAGE
var big_bullet_damage := BASE_BIG_DAMAGE
var reloaded := true
var target_pos : Vector2

onready var animator: AnimationPlayer = $Animator

func _ready():
	animator.play("idle")

func update_stats():
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.065))
	small_bullet_damage = BASE_SMALL_DAMAGE + (TowerDict.stats[id]["Damage"] * 3.2)
	big_bullet_damage = BASE_BIG_DAMAGE + (TowerDict.stats[id]["Damage"] * 14.0)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.5)

func _process(delta):
	if reloaded and animator.current_animation == "idle":
		prepare_shot()

func prepare_shot():
	var aim_pos = select_target_position(BIG_BULLET_SPEED, range_offset, "close")
	if aim_pos == Vector2.ZERO:
		return
	
	target_pos = aim_pos
	var aim_dir := (global_position + range_offset).direction_to(aim_pos)
	if aim_dir.x < -0.55:
		animator.play("shoot_left")
	elif aim_dir.x > 0.55:
		animator.play("shoot_right")
	elif aim_dir.y < 0.0:
		animator.play("shoot_up")
	else:
		animator.play("shoot_down")
	reloaded = false

func shoot(offset : Vector2, big := false):
	var instance : Bullet
	if big:
		instance = big_bullet.instance()
	else:
		instance = small_bullet.instance()
	get_parent().add_child(instance)
	if big:
		instance.create_bullet(position + offset, target_pos, BIG_BULLET_SPEED, big_bullet_damage, 0.01)
	else:
		instance.create_bullet(position + offset, target_pos, SMALL_BULLET_SPEED, small_bullet_damage, SMALL_BULLET_INACCURACY)

func reload():
	reloaded = true

func _on_animation_finished(anim_name: String):
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")
	animator.play("idle")
