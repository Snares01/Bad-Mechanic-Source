extends Mob

const SPEED_VAR := 1.0
const CASH_REWARD := 8
const BUBBLE_RELOAD := 0.5
const NORMAL_SPEED := 6.0
const MIN_BUBBLE_SPEED := 10.0
const MAX_BUBBLE_SPEED := 14.0

onready var animator: AnimationPlayer = $Animator

var bubble_reloaded := true

func _ready():
	animator.play("walk")
	set_flash_sprite($Sprite)
	base_speed = NORMAL_SPEED
	death_knockback_velocity = 16
	death_knockback_decay = 3

func _process(delta):
	if not is_dead:
		path_move(speed * delta)

# Override
func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
	if animator.current_animation == "bubble":
		return
	.take_damage(damage, direction, effect)
	if bubble_reloaded and not is_dead and stun < 0.1:
		bubble_reloaded = false
		animator.play("bubble")
		base_speed = rand_range(MIN_BUBBLE_SPEED, MAX_BUBBLE_SPEED)

func on_death(direction : Vector2):
	animator.play("die")
	var timer := get_tree().create_timer(0.5, false)
	timer.connect("timeout", self, "_flash")

func _flash():
	flash_material.set_shader_param("flash", 1.0)
	var timer := get_tree().create_timer(0.05)
	timer.connect("timeout", self, "_die")

func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_REWARD, 18)
	queue_free()


func _on_animation_finished(anim_name):
	animator.play("walk")
	var timer := get_tree().create_timer(BUBBLE_RELOAD, false)
	timer.connect("timeout", self, "reload")
	base_speed = NORMAL_SPEED

func reload():
	bubble_reloaded = true
