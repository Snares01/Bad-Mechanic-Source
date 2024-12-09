extends Tower

const BASE_RANGE := 50.0
const BASE_STUN := 4.4
const BASE_RELOAD := 1.3
const BULLET_SPEED := 60.0
const BULLET_LIFESPAN := 3.0
const BULLET_DECAY := 8.0
const AIM_OFFSET := Vector2(0, -6)
const FRONT_POS := Vector2(6, -4)
const SIDE_POS := Vector2(10, -6.5)
const BACK_POS := Vector2(6, -11)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var stun := BASE_STUN
var reloaded := true

func update_stats():
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.06))
	stun = BASE_STUN + (TowerDict.stats[id]["Stun"] * 0.4)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.5)

func _process(delta):
	if active and reloaded:
		shoot()

func shoot():
	reloaded = false
	var aim_pos = select_target_position(BULLET_SPEED, AIM_OFFSET, "strong")
	if aim_pos == Vector2.ZERO:
		return
	
	var aim_dir := (global_position + AIM_OFFSET).direction_to(aim_pos)
	var offset := AIM_OFFSET
	if aim_dir.y < -0.5:
		offset = BACK_POS
	elif aim_dir.y < 0.5:
		offset = SIDE_POS
	else:
		offset = FRONT_POS
	if aim_dir.x < 0:
		offset.x *= -1
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + offset, aim_pos, BULLET_SPEED, stun, 0.05,
	  BULLET_LIFESPAN, BULLET_DECAY, Bullet.effect.STUN)
	
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
