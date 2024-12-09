extends Mob

const SPEED_VAR := 2.0
const DEATH_ANIM_LENGTH := 0.5
const BONUS_CASH := 40.0 # level 5 boss reward

export var trojan_mode := false
export var devil_mode := false

onready var rng = SignalBus.rng
var death_flash_timer := 0.05
var is_flash_on := false

func _ready():
	set_flash_sprite($Sprite)
	base_speed += rand_range(-SPEED_VAR, SPEED_VAR)
	death_knockback_velocity = 15
	death_knockback_decay = 1
	if trojan_mode:
		$Animator.play("Run1")
	else:
		var anim := "Run" + str(rng.randi_range(1, 5))
		$Animator.play(anim, -1, 1.1)


func _process(delta):
	if is_dead:
		if is_flash_on:
			flash -= delta
			if flash < 0.0:
				pass
		return
	path_move(speed * delta)


func on_death(direction):
	if direction.x < 0:
		if $Sprite.flip_h == true:
			$Sprite.rotation_degrees = 90
		else:
			$Sprite.rotation_degrees = -90
	else:
		if $Sprite.flip_h == true:
			$Sprite.rotation_degrees = -90
		else:
			$Sprite.rotation_degrees = 90
	
	var timer : SceneTreeTimer = get_tree().create_timer(DEATH_ANIM_LENGTH, false)
	timer.connect("timeout", self, "_flash_begin")

func _flash_begin():
	flash_material.set_shader_param("flash", 1.0)
	var timer : SceneTreeTimer = get_tree().create_timer(0.05)
	timer.connect("timeout", self, "_die")

func _die():
	var cash_reward := 2
	if devil_mode:
		queue_free()
		return
	get_parent().create_cash(global_position + aim_offset, cash_reward, 18)
	queue_free()
