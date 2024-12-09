extends Mob

const CASH_AMOUNT := 11
const STEP_SIZE := 6.0 # Pixels per second
const STEP_TIME := 0.15


func _ready():
	set_flash_sprite($Sprite)
	death_knockback_velocity = 45.0
	death_knockback_decay = 5.0
	step()

func step():
	if is_dead:
		return
		
	var timer := get_tree().create_timer(STEP_TIME, false)
	timer.connect("timeout", self, "step")
	
	if stun > 0.1:
		return
	
	if sprite.frame == 0:
		sprite.frame = 1
	else:
		sprite.frame = 0
	path_move(STEP_SIZE * STEP_TIME)

func on_death(direction : Vector2):
	sprite.frame = 2
	sprite.offset = Vector2(0, 3)
	var timer := get_tree().create_timer(0.8)
	timer.connect("timeout", self, "death_flash")

func death_flash():
	flash_material.set_shader_param("flash", 1.0)
	var timer := get_tree().create_timer(0.05)
	timer.connect("timeout", self, "die")

func die():
	get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 60)
	queue_free()
