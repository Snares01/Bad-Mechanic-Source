extends Tower

const BULLET_SPEED_DECAY := 7.5
const BULLET_LIFESPAN := 3.0
const BULLET_SPEED := 40.0
const BASE_RELOAD := 0.6
const BASE_DAMAGE := 16.0
const BASE_RANGE := 46.0
const OFFSET_0 := Vector2(-9, -17) # Sprite offsets for each cannon
const OFFSET_1 := Vector2(9, -17)
const OFFSET_2 := Vector2(-9, -6.5)
const OFFSET_3 := Vector2(9, -6.5)
const ANGLE_0 := -145.0 # Bullet angles for each cannon
const ANGLE_1 := -35.0
const ANGLE_2 := 150.0
const ANGLE_3 := 30.0

export var bullet : Resource

var reload_time := BASE_RELOAD
var bullet_damage := BASE_DAMAGE

onready var animator = $Animator

func _ready():
	animator.play("Idle")


func update_stats(): # 15 Levels
	reload_time = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.03))
	bullet_damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 1.4)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.5)


func shoot(rng : RandomNumberGenerator):
	# 0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right
	var cannon := rng.randi_range(0, 3)
	
	var instance : Bullet = bullet.instance()
	var angle := ANGLE_0
	var offset := OFFSET_0
	
	if cannon == 0:
		animator.play("Shoot_0")
	elif cannon == 1:
		animator.play("Shoot_1")
		angle = ANGLE_1
		offset = OFFSET_1
	elif cannon == 2:
		animator.play("Shoot_2")
		angle = ANGLE_2
		offset = OFFSET_2
	else:
		animator.play("Shoot_3")
		angle = ANGLE_3
		offset = OFFSET_3
	
	get_parent().add_child(instance)
	instance.create_bullet(position + offset, deg2rad(angle), BULLET_SPEED,
		bullet_damage, 0.0, BULLET_LIFESPAN, BULLET_SPEED_DECAY)
	

func activate():
	if animator.current_animation == "Idle":
		shoot(SignalBus.rng)


func _on_animation_finished(_anim_name):
	if active:
		$Reload.start(reload_time)
	else:
		animator.play("Idle")


func _on_reload_timeout():
	if active:
		shoot(SignalBus.rng)
	else:
		animator.play("Idle")
