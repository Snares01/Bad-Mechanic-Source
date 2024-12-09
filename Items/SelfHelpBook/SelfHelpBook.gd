extends ItemEffect

func effect():
	SignalBus.change_max_health(25)
	SignalBus.change_health(-25)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
