extends Tower

const BASE_RELOAD := 1.1
const BASE_POISON := 25.0
const BASE_RANGE := 55.0
const BULLET_SPEED := 66.0
const AIM_OFFSET := Vector2(4, -7)
const AIM_OFFSET_UP := Vector2(4, -11)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var poison_damage := BASE_POISON
var reloaded := true

func update_stats():
	reload_speed = BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.06)
	poison_damage = BASE_POISON + (TowerDict.stats[id]["Poison"] * 2.0)
	sight_range = BASE_RANGE

func _process(delta):
	if active and reloaded:
		shoot()

func shoot():
	var aim_pos = select_target_position(BULLET_SPEED, AIM_OFFSET, "strong")
	if aim_pos == Vector2.ZERO:
		return
	var aim_offset := AIM_OFFSET
	if aim_pos.y < (global_position + AIM_OFFSET).y:
		aim_offset = AIM_OFFSET_UP
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + aim_offset, aim_pos, BULLET_SPEED,
	  -poison_damage, 0.0, 10.0, 0.0, Bullet.effect.POISON)
	
	reloaded = false
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
