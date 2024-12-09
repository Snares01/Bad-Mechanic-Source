extends Mob

const EXPLOSION := preload("res://Towers/!Resources/Explosion.tscn")
const SPEED_VARIATION := 0.5
const CASH_AMOUNT := 12

var driver_type : int

onready var driver_spr := $Driver

func _ready():
	base_speed += rand_range(-SPEED_VARIATION, SPEED_VARIATION)
	set_flash_sprite($Sprite)
	death_knockback_velocity = 55.0
	death_knockback_decay = 6.5
	driver_type = SignalBus.rng.randi_range(0, 3)
	$Animator.play("move")


func _process(delta):
	if is_dead:
		return
	path_move(speed * delta)
	if sprite.flip_h:
		driver_spr.flip_h = true
	else:
		driver_spr.flip_h = false


func on_death(direction : Vector2):
	if direction.y > 0:
		$Animator.play("die_down")
	else:
		$Animator.play("die_up")

func set_relative_frame(frame : int):
	driver_spr.frame = frame + (3 * driver_type)

func set_flash(flash : bool):
	if flash:
		flash_material.set_shader_param("flash", 1.0)
	else:
		flash_material.set_shader_param("flash", 0.0)

func _on_animation_finished(anim_name : String):
	var instance := EXPLOSION.instance()
	instance.global_position = global_position + aim_offset
	get_parent().add_child(instance)
	get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 60)
	queue_free()
