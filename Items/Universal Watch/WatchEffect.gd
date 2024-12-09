extends ItemEffect

const EFFECT_DURATION := 5.0
const TARGET_SPEED := 0.5

var effect := false
var lifespan := EFFECT_DURATION

func effect() -> void:
	lifespan = EFFECT_DURATION
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	effect = true


func _on_timeout():
	effect = false
	sfx.stream = SFX_DEACTIVATE
	sfx.play()


func kill():
	effect = false
	Engine.time_scale = 1.0
	AudioServer.global_rate_scale = 1.0


func _process(delta):
	if effect:
		# (delta * ((Engine.time_scale - 0.4) * 2))
		Engine.time_scale = max(Engine.time_scale - delta, TARGET_SPEED)
		AudioServer.global_rate_scale = 1.0 / Engine.time_scale
		lifespan -= delta / Engine.time_scale
		if lifespan < 0.0:
			_on_timeout()
	else:
		Engine.time_scale = min(Engine.time_scale + delta, 1.0)
		AudioServer.global_rate_scale = 1.0 / Engine.time_scale
		if Engine.time_scale > 0.99:
			kill()
			queue_free()
