extends Tower

const aim_pos_list := [
	Vector2(0, -8), Vector2(-5, -8), Vector2(-8.5, -8.5),
	Vector2(-12, -10.5), Vector2(-13.5, -12.5), Vector2(-13, -15),
	Vector2(-11.5, -18), Vector2(-8, -20), Vector2(-4.5, -20), Vector2(0, -20)]
const aim_origin := Vector2(0, -13.5)
const tick_time := 0.2

const BASE_RELOAD := 2.0
const BASE_DAMAGE := 35.0
const BASE_LIFESPAN := 3.0 #4.5
const BASE_BULLET_SPEED := 30.0 # 20.0
const BASE_SPEED_DECAY := 4.5 # 3.0
const BASE_RANGE := 55.0

var target_frame := 0
var offset := Vector2.ZERO
var aim_pos : Vector2

var bullet_speed := BASE_BULLET_SPEED
var bullet_damage := BASE_DAMAGE
var bullet_lifespan := BASE_LIFESPAN
var bullet_speed_decay := BASE_SPEED_DECAY
var reload_time := BASE_RELOAD

export var bullet : Resource

onready var gun := $Sprite/Gun
onready var timer := $Timer


func update_stats():
	reload_time = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Speed"] * 0.1))
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 2.5)
	bullet_lifespan = BASE_LIFESPAN + (TowerDict.stats[id]["Bullet Lifespan"] * 0.16)
	bullet_speed = max(15.0, BASE_BULLET_SPEED - (TowerDict.stats[id]["Bullet Lifespan"] * 1))
	bullet_speed_decay = max(1.0, BASE_SPEED_DECAY - (TowerDict.stats[id]["Bullet Lifespan"] * 0.1))
	sight_range = BASE_RANGE

func _physics_process(delta):
	pass

# Returns frame to aim at
func get_aim_target(aim_pos) -> int:
	var aim_dir = round((sin(get_angle_to(aim_pos)) * -1 + 1) * 0.9 / 0.2) # range of 0-9
	if aim_pos.x > global_position.x:
		aim_dir *= -1
	return aim_dir


func shoot():
	timer.start(reload_time)
	
	offset = aim_pos_list[gun.frame]
	if gun.flip_h:
		offset.x *= -1
	
	var instance : AreaOfEffect = bullet.instance()
	get_parent().add_child(instance)
	instance.create_aoe(position + offset, aim_pos, bullet_speed, 0.1, bullet_lifespan, bullet_speed_decay)
	instance.damage = bullet_damage


func _on_Timer_timeout():
	# Update target frame
	aim_pos = select_target_position(bullet_speed, Vector2(0, -9.5), "close")
	if aim_pos == Vector2.ZERO:
		target_frame = 0
	else:
		target_frame = get_aim_target(aim_pos)
		if abs(target_frame) == gun.frame:
			if not ((target_frame < 0 and not gun.flip_h) or (target_frame > 0 and gun.flip_h)):
				shoot()
				return
	
	# Move towards target frame (idk how it works)
	if target_frame == gun.frame:
		return
	elif target_frame < 0 and int(gun.flip_h) == 0 or target_frame > 0 and int(gun.flip_h) == 1:
		# Different sides
		if abs(target_frame) + gun.frame < 10:
			if gun.frame == 0:
				gun.frame += 1
				if gun.flip_h:
					gun.flip_h = false
				else:
					gun.flip_h = true
			else:
				gun.frame -= 1
		else:
			if gun.frame == 9:
				gun.frame -= 1
				if gun.flip_h:
					gun.flip_h = false
				else:
					gun.flip_h = true
			gun.frame += 1
	else:
		# Same side
		if abs(target_frame) < gun.frame:
			gun.frame -= 1
		else:
			gun.frame += 1
	
	timer.start(tick_time)
