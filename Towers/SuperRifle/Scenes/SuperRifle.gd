extends Tower

const BASE_BULLETS := 10
const BASE_RELOAD := 1.2
const BASE_DAMAGE := 30.0
const BASE_RANGE := 75.0
const BULLET_SPEED := 55.0
const AIM_OFFSET := Vector2(0, -8)
const AIM_TIME := 0.25
const TIME_BETWEEN_BULLETS := 0.08
const AIM_AHEAD := 48.0

export var bullet : Resource
var reload_speed := BASE_RELOAD
var bullets_per_burst := BASE_BULLETS
var bullet_damage := BASE_DAMAGE
var reloaded := true
var current_bullet := 0
var aim_dir : float

func update_stats():
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.06))
	bullets_per_burst = BASE_BULLETS + round((TowerDict.stats[id]["Burst"] * 1.5))
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 3.0)
	sight_range = BASE_RANGE

func _process(delta):
	if active and reloaded:
		reloaded = false
		aim_dir = (global_position + AIM_OFFSET).direction_to(select_target_position(AIM_AHEAD, AIM_OFFSET)).angle()
		shoot()

func shoot():
	current_bullet += 1
	if current_bullet >= bullets_per_burst:
		current_bullet = 0
		$Sprite.frame = 0
		var timer := get_tree().create_timer(reload_speed)
		timer.connect("timeout", self, "reload")
	else:
		$Sprite.frame = 1
		var timer := get_tree().create_timer(TIME_BETWEEN_BULLETS)
		timer.connect("timeout", self, "shoot")
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + AIM_OFFSET, aim_dir, BULLET_SPEED, bullet_damage, 0)

func reload():
	reloaded = true
