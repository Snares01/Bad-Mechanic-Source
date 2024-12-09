extends Tower

const BASE_RELOAD := 2.0 # Higher number = shorter reload
const BASE_FREEZE := 60.0
const BASE_RANGE := 33.0
const SNOWBALL_SPEED := 55.0
const AIM_OFFSET := Vector2(0, -14)
const PRE_AIM_OFFSET := Vector2(0, -8)
const INACCURACY := 0.08

export var bullet : Resource

var reload_speed := BASE_RELOAD
var freeze_damage := BASE_FREEZE
var reloaded := false
var target_mob : Mob

onready var animator := $Animator

func _ready():
	animator.play("Reload")

func update_stats():
	reload_speed = BASE_RELOAD + (TowerDict.stats[id]["Reload"] * 0.2)
	freeze_damage = BASE_FREEZE + (TowerDict.stats[id]["Freeze"] * 5.0)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.5)


func _process(delta):
	if active and reloaded and animator.current_animation != "Throw":
		animator.play("Throw")
		select_target()
		reloaded = false

# Called by animator
func select_target():
	target_mob = select_target_mob(SNOWBALL_SPEED, PRE_AIM_OFFSET)
	if target_mob == null:
		animator.play("Reload")
	else:
		if target_mob.global_position.x < global_position.x:
			$Body.flip_h = true
			$Arm.flip_h = true
			$Arm.position.x = 3
		else:
			$Body.flip_h = false
			$Arm.flip_h = false
			$Arm.position.x = -3

func shoot():
	if is_target_valid(target_mob, SNOWBALL_SPEED, PRE_AIM_OFFSET):
		var aim_pos := get_aim_position(target_mob, SNOWBALL_SPEED, AIM_OFFSET)
		
		var instance : Bullet = bullet.instance()
		get_parent().add_child(instance)
		instance.create_bullet(position + AIM_OFFSET, aim_pos, SNOWBALL_SPEED,
			-freeze_damage, INACCURACY, 4, 8, Bullet.effect.FREEZE)

func _on_animation_finished(anim_name : String):
	if anim_name == "Reload":
		reloaded = true
	elif anim_name == "Throw":
		animator.play("Reload", -1, reload_speed)
