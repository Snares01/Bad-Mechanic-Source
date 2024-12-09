extends ItemEffect

func effect():
	SignalBus.change_max_health(50.0)
	SignalBus.change_health(-50.0)
	Modifiers.poison_multiplier /= 1.6
	sfx.stream = SFX_ACTIVATE
	sfx.play()
