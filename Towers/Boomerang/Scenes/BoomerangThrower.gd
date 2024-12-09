extends Tower

const BASE_RELOAD := 2.66
const BASE_DAMAGE := 28.0
const BASE_RANGE := 50.0
const BASE_BOOM_SPEED := 75.0
const AIM_OFFSET := Vector2(0, -9)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var damage := BASE_DAMAGE
var boomerang_speed := BASE_BOOM_SPEED
var reloaded := true


func update_stats():
	reload_speed = max(0.2, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.18))
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 2.1)
	sight_range = BASE_RANGE

func _process(delta):
	if active and reloaded:
		shoot()

func shoot():
	var aim_pos = select_target_position(boomerang_speed * 0.55, AIM_OFFSET)
	if aim_pos == Vector2.ZERO:
		return
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + AIM_OFFSET, aim_pos, boomerang_speed,
	  damage, 0.0, 3.0, boomerang_speed / 1.5)
	
	reloaded = false
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
