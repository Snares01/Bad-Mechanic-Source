extends ItemEffect

func effect():
	SignalBus.change_health(-SignalBus.max_health * 0.5)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
