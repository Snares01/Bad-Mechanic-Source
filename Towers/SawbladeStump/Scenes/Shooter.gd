extends Tower

const BASE_RELOAD := 2.0
const BASE_DAMAGE := 12.0 # damage per second
const BASE_RANGE := 40.0
const BASE_LIFESPAN := 5.5
const BLADE_SPEED := 38.0
const BLADE_HIT_RATE := 0.1
const AIM_OFFSET := Vector2(-0.5, -6)
const AIM_OFFSET_UP := Vector2(-0.5, -9)
const AIM_OFFSET_DOWN := Vector2(-0.5, -3)
const AIM_OFFSET_LEFT := Vector2(-7, -5)
const AIM_OFFSET_RIGHT := Vector2(6, -5)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var bullet_damage := BASE_DAMAGE
var bullet_lifespan := BASE_LIFESPAN
var reloaded := true

func update_stats():
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.07))
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 1.2)
	bullet_lifespan = BASE_LIFESPAN + (TowerDict.stats[id]["Lifespan"] * 0.7)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.0)

func _process(delta):
	if active and reloaded:
		shoot()

func shoot():
	var aim_pos = select_target_position(BLADE_SPEED, AIM_OFFSET)
	if aim_pos == Vector2.ZERO:
		return
	var aim_offset := Vector2(cos(get_angle_to(aim_pos)), sin(get_angle_to(aim_pos)))
	if aim_offset.x < -0.6:
		aim_offset = AIM_OFFSET_LEFT
	elif aim_offset.x > 0.6:
		aim_offset = AIM_OFFSET_RIGHT
	elif aim_offset.y < 0:
		aim_offset = AIM_OFFSET_UP
	else:
		aim_offset = AIM_OFFSET_DOWN
	
	var instance : AreaOfEffect = bullet.instance()
	get_parent().add_child(instance)
	instance.create_aoe(position + aim_offset, aim_pos, BLADE_SPEED, 0.1, bullet_lifespan)
	instance.damage = bullet_damage
	
	reloaded = false
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
