extends Tower

const BASE_SPEED = 30.0
const BASE_DAMAGE = 4.0
const BASE_RELOAD = 0.6
const BASE_RANGE = 38.0

export var bullet : Resource
var bullet_speed := BASE_SPEED
var bullet_damage := BASE_DAMAGE
var reload_speed := BASE_RELOAD # speed of shoot anim
# aiming & enemy detection
func _ready():
	$Animator.play("Idle")


func update_stats():
	reload_speed = BASE_RELOAD + (TowerDict.stats[id]["Speed"] * 0.06)
	bullet_speed = BASE_SPEED + (TowerDict.stats[id]["Speed"] * 1.0)
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 0.55)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.5)


func shoot(offset : Vector2):
	var aim_pos = select_target_position(bullet_speed, offset)
	if aim_pos == Vector2.ZERO:
		return
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + offset, aim_pos, bullet_speed, bullet_damage, 0.025)


func _on_animation_finished(anim_name):
	if get_overlapping_areas().empty():
		$Animator.play("Idle")
	else:
		$Animator.play("Shoot", -1, reload_speed)
