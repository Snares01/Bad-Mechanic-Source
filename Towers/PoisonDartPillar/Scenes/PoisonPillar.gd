extends Tower

const BASE_RELOAD := 2.0 # Time between shots
const BASE_POISON := 15.0
const BASE_RANGE := 40.0
const DART_SPEED := 60.0
const AIM_OFFSET := Vector2(-0.5, -10.0)
const AIM_DOWN := Vector2(-0.5, -6.5)
const AIM_DOWN_LEFT := Vector2(-7.5, -8.5)
const AIM_DOWN_RIGHT := Vector2(6.5, -8.5)
const AIM_UP := Vector2(-0.5, -14.5)
const AIM_UP_LEFT := Vector2(-7.5, -13.0)
const AIM_UP_RIGHT := Vector2(6.5, -13.0)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var poison_damage := BASE_POISON
var reloaded := true

func update_stats():
	reload_speed = max(0.2, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.13))
	poison_damage = BASE_POISON + (TowerDict.stats[id]["Poison"] * 2.5)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.0)

func _process(delta):
	if active and reloaded:
		shoot()

func shoot():
	var aim_pos = select_target_position(DART_SPEED, AIM_OFFSET)
	if aim_pos == Vector2.ZERO:
		return
	
	# TODO: spawn from particular gun depending on aim dir
	var aim_offset : Vector2
	var aim_dir := (global_position + AIM_OFFSET).direction_to(aim_pos)
	if aim_dir.x < -0.5:
		if aim_dir.y < 0:
			aim_offset = AIM_UP_LEFT
		else:
			aim_offset = AIM_DOWN_LEFT
	elif aim_dir.x > 0.5:
		if aim_dir.y < 0:
			aim_offset = AIM_UP_RIGHT
		else:
			aim_offset = AIM_DOWN_RIGHT
	else:
		if aim_dir.y < 0:
			aim_offset = AIM_UP
		else:
			aim_offset = AIM_DOWN
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + aim_offset, aim_pos, DART_SPEED, -poison_damage,
	  0.0, 10.0, 0.0, Bullet.effect.POISON)
	
	reloaded = false
	var timer := get_tree().create_timer(reload_speed)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
