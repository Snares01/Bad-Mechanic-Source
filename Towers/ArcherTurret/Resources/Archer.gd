extends Sprite

const AIM_OFFSET := Vector2(6, -1)

export var bullet : Resource

onready var animator : AnimationPlayer = $Animator
onready var tower : Tower = get_parent()

func _ready():
	animator.play("idle")

func _process(delta):
	if tower.active and animator.current_animation == "idle":
		animator.play("shoot", -1, tower.shoot_speed)

# called by animation
func shoot():
	var aim_pos = tower.select_target_position(tower.arrow_speed, Vector2.ZERO, "strong")
	if aim_pos == Vector2.ZERO:
		return
	var aim_offset := AIM_OFFSET
	if aim_pos.x < global_position.x:
		flip_h = true
		aim_offset.x *= -1
	else:
		flip_h = false
	#aim_pos = tower.select_target_position(tower.arrow_speed, aim_offset, "strong")
	#if aim_pos == Vector2.ZERO:
	#	return
	
	var instance : Bullet = bullet.instance()
	tower.get_parent().add_child(instance)
	instance.create_bullet(global_position + aim_offset, aim_pos, tower.arrow_speed, tower.damage)

# called by animation
func check_mobs():
	if tower.active:
		animator.play("shoot", -1, tower.shoot_speed)
	else:
		animator.play("idle")
