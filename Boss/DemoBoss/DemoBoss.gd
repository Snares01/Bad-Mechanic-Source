extends Boss

export var speed := 7.0

func _ready():
	sprite.frame = 6
	set_flash_sprite(sprite)
	animator.play("intro", -1, 0.5)


func _process(delta):
	var dir : Vector2 = position.direction_to(player_ref.position)
	if dir.x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	move_and_slide(dir * speed)


func _on_animation_finished(anim_name: String):
	if anim_name == "intro":
		end_intro()
		animator.play("run")
	elif anim_name == "death":
		get_parent().create_cash(position, 45, 60)
		queue_free()


func on_death(direction : Vector2):
	set_process(false)
	animator.play("death")
