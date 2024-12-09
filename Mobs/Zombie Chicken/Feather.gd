extends Sprite

export var fall_speed := 0.0
export var momentum := Vector2()

var height := 30.0
var floor_pos := Vector2.ZERO
var is_falling := true

func _ready():
	$Animator.play("Fall")
	$Animator.advance(randf())
	height = rand_range(4.5, 13)


func _process(delta):
	if is_falling:
		height -= fall_speed * delta
		position = floor_pos + Vector2(0, -height)
		if height < 0 and frame != 3 and frame != 0: # transition from frame 3/0 is ugly
			is_falling = false
			$Animator.play("Lay")
	else:
		position += momentum * delta


func _on_animation_finished(anim_name):
	# death anim
	queue_free()
