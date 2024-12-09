extends ItemEffect

func effect():
	SignalBus.change_max_health(50.0)
	SignalBus.change_health(-50.0)
	Modifiers.freeze_multiplier *= 0.33
	sfx.stream = SFX_ACTIVATE
	sfx.play()
