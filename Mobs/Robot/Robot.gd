extends Mob

const SPEED_VAR := 2.0
const CASH_REWARD := 7


func _ready():
	$AnimationPlayer.play("vroom")
	set_flash_sprite($Sprite)
	base_speed += rand_range(-SPEED_VAR, SPEED_VAR)
	death_knockback_velocity = 38
	death_knockback_decay = 12

func _process(delta):
	if not is_dead:
		path_move(speed * delta)

func on_death(direction : Vector2):
	$AnimationPlayer.play("die")
	var timer := get_tree().create_timer(0.7, false)
	timer.connect("timeout", self, "_flash")

func _flash():
	flash_material.set_shader_param("flash", 1.0)
	var timer := get_tree().create_timer(0.05)
	timer.connect("timeout", self, "_die")

func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_REWARD, 18)
	queue_free()
