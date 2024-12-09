extends ItemEffect

func effect():
	var health_change := SignalBus.max_health
	SignalBus.change_max_health(health_change)
	SignalBus.change_health(-health_change)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
