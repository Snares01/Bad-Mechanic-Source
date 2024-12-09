extends Tower

const BASE_RELOAD := 0.33 # Time between shots while spinning
const BASE_SPIN_SPEED := 1.0 # Animation speed
const BASE_DAMAGE := 3.0
const BASE_INACCURACY := 0.55
const BASE_RANGE := 50.0
const BULLET_SPEED := 45.0
const SPR_OFFSET := Vector2(-0.5, -7)

export var bullet : Resource
var reload_speed := BASE_RELOAD
var spin_speed := BASE_SPIN_SPEED
var damage := BASE_DAMAGE
var inaccuracy := BASE_INACCURACY

onready var animator := $Animator

func _ready():
	animator.play("idle")

func update_stats():
	reload_speed = max(BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.012), 0.025)
	spin_speed = BASE_SPIN_SPEED + (TowerDict.stats[id]["Reload"] * 0.07)
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 0.25)
	inaccuracy = max(BASE_INACCURACY - (TowerDict.stats[id]["Accuracy"] * 0.033), 0.05)
	sight_range = BASE_RANGE

func _process(delta):
	if animator.current_animation == "idle" and active:
		animator.play("spin_start")

# called by animator
func shoot():
	var aim_pos = select_target_position(BULLET_SPEED, SPR_OFFSET, "close")
	if aim_pos == Vector2.ZERO:
		return
	
	var aim_offset := SPR_OFFSET
	var aim_dir := (global_position + SPR_OFFSET).direction_to(aim_pos).rotated(rand_range(-inaccuracy/2, inaccuracy/2))
	aim_offset.y += aim_dir.y * 6
	aim_offset.x += aim_dir.x * 8
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + aim_offset, aim_pos, BULLET_SPEED, damage, inaccuracy)

# called by animator
func spin_check():
	if not active:
		animator.play("spin_end")

func _on_animation_finished(anim_name : String):
	if anim_name == "spin_start":
		animator.play("spin", -1, spin_speed)
	elif anim_name == "spin_end":
		animator.play("idle")
