extends Tower

const BASE_SPIN_SPEED := 1.0
const BASE_DAMAGE := 18.0
const BASE_RANGE := 40.0
const INACCURACY := 0.18
const BULLET_SPEED := 36.0
const AIM_OFFSET := Vector2(0, -10)

export var bullet : Resource
var spin_speed := BASE_SPIN_SPEED
var damage := BASE_DAMAGE

onready var animator : AnimationPlayer = $Animator

func _ready():
	animator.play("idle")

func update_stats():
	spin_speed = BASE_SPIN_SPEED + (TowerDict.stats[id]["Reload"] * 0.06)
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 1.7)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 3.5)

func _process(delta):
	if animator.current_animation == "idle" and active:
		animator.play("spin_start")

# called by anim
func shoot():
	var aim_pos = select_target_position(BULLET_SPEED, AIM_OFFSET, "close")
	if aim_pos == Vector2.ZERO:
		return
	
	var aim_offset1 := AIM_OFFSET
	var aim_offset2 := AIM_OFFSET
	var aim_dir := (global_position + AIM_OFFSET).direction_to(aim_pos).rotated(rand_range(-INACCURACY, INACCURACY))
	aim_offset1.y += aim_dir.y * 8
	aim_offset1.x += aim_dir.x * 12
	aim_offset2.y -= aim_dir.y * 8
	aim_offset2.x -= aim_dir.x * 12
	
	var instance1 : Bullet = bullet.instance()
	var instance2 : Bullet = bullet.instance()
	get_parent().add_child(instance1)
	get_parent().add_child(instance2)
	instance1.create_bullet(position + aim_offset1, aim_dir.angle(), BULLET_SPEED, damage)
	instance2.create_bullet(position + aim_offset2, aim_dir.rotated(PI).angle(), BULLET_SPEED, damage)

# called by animator
func spin_check():
	if not active:
		animator.play("spin_end")

func _on_animation_finished(anim_name : String):
	if anim_name == "spin_start":
		animator.play("spin", -1, spin_speed)
	elif anim_name == "spin_end":
		animator.play("idle")
