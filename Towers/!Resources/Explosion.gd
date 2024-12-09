extends Hitbox

const HIT_DAMAGE_MULTIPLIER = 0.925

func _ready():
	$Animator.play("Explode")
	$Animator.connect("animation_finished", self, "_on_animation_finished")
	yield(get_tree(), "idle_frame")
	SignalBus.emit_signal("destroy_area", global_position, 4)


func _on_animation_finished(anim_name: String):
	hide()


func _on_SoundEffect_finished():
	queue_free()
