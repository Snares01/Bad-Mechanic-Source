extends Area2D

export var reflect_pos : Vector2

func _ready():
	$Animator.play("blip")

# Bullets just need to detect that this function exists to reflect. idk.
func reflect():
	pass

func _on_animation_finished(anim_name):
	queue_free()
