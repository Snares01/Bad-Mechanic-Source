extends ItemEffect

func effect():
	SignalBus.change_max_health(50.0)
	SignalBus.change_health(-50.0)
	Modifiers.stun_multiplier *= 0.25
	sfx.stream = SFX_ACTIVATE
	sfx.play()
