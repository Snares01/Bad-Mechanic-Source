extends Tower

const BASE_DAMAGE = 8.0
const BASE_RELOAD = 1.9
const BASE_RANGE = 55.0
const BULLET_SPEED := 36.0
const BASE_ACCURACY := 0.3

export var bullet : Resource
var bullet_damage := BASE_DAMAGE
var reload_speed := BASE_RELOAD
var accuracy := BASE_ACCURACY
var is_reload_finished := true

onready var animator := $Animator

func _ready():
	animator.play("Idle")


func update_stats():
	reload_speed = max(BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.14), 0)
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 1.1)
	accuracy = max(BASE_ACCURACY - (TowerDict.stats[id]["Accuracy"] * 0.04), 0.0)
	sight_range = BASE_RANGE


func _process(delta):
	if active and is_reload_finished and animator.current_animation == "Idle":
		animator.play("Shoot")
		is_reload_finished = false


func shoot(offset : Vector2):
	var aim_pos = select_target_position(BULLET_SPEED, offset + Vector2(0, 4))
	if aim_pos == Vector2.ZERO:
		return
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + offset, aim_pos, BULLET_SPEED, bullet_damage, accuracy)


func _on_animation_finished(anim_name):
	if anim_name == "Shoot":
		var timer := get_tree().create_timer(reload_speed)
		timer.connect("timeout", self, "reload")
		animator.play("Idle")


func reload():
	is_reload_finished = true
