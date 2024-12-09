extends Mob

const SPEED_VARIATION := 2.2
const CASH_AMOUNT := 7

export var run_anim_speed := 1.0


func _ready():
	$Animator.play("Run", -1, run_anim_speed)
	base_speed += rand_range(-SPEED_VARIATION, SPEED_VARIATION)
	set_flash_sprite($Sprite)
	death_knockback_velocity = 50.0
	death_knockback_decay = 5.0


func _process(delta):
	if is_dead:
		return
	path_move(speed * delta)


func on_death(direction : Vector2):
	if direction.x < 0:
		if sprite.flip_h == true:
			$Animator.play("Fall Forward")
		else:
			$Animator.play("Fall Back")
	else:
		if sprite.flip_h == true:
			$Animator.play("Fall Back")
		else:
			$Animator.play("Fall Forward")


func _on_animation_finished(anim_name : String):
	if anim_name == "Run":
		return
	# After death anim
	get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 35.0)
	queue_free()
