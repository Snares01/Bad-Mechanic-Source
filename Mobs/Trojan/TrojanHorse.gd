extends Mob

const RUNNING_SPEED := 7.0
const MIN_TIME_WAIT := 3.0
const MAX_TIME_WAIT := 8.0
const MIN_TIME_RUN := 5.0
const MAX_TIME_RUN := 12.5
const CASH_AMOUNT := 12


var trojan_man := preload("res://Mobs/Trojan/TrojanMan.tscn")
var is_running := true

func _ready():
	set_flash_sprite($Sprite)
	$Animator.play("Run")
	death_knockback_velocity = 0
	base_speed = RUNNING_SPEED
	$Timer.start(rand_range(MIN_TIME_RUN, MAX_TIME_RUN))


func _process(delta):
	if is_running:
		path_move(speed * delta)


func on_death(direction):
	$Timer.stop()
	is_running = false
	$Animator.play("Death")


func _on_timer_timeout():
	if is_running:
		$Timer.start(rand_range(MIN_TIME_WAIT, MAX_TIME_WAIT))
		$Animator.play("Wait")
		is_running = false
		base_speed = 0
	else:
		$Timer.start(rand_range(MIN_TIME_RUN, MAX_TIME_RUN))
		$Animator.play("Run")
		is_running = true
		base_speed = RUNNING_SPEED


func _on_animation_finished(anim_name):
	if anim_name == "Death":
		# Spawn trojans
		var instance : Mob = trojan_man.instance()
		instance.path = path
		instance.path_progress = path_progress
		instance.path_offset = Vector2(-3, 0)
		get_parent().add_child(instance)
		instance = trojan_man.instance()
		instance.path = path
		instance.path_progress = path_progress
		instance.path_offset = Vector2(3, 0)
		get_parent().add_child(instance)
		# die and be dead
		get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 45.0)
		queue_free()
