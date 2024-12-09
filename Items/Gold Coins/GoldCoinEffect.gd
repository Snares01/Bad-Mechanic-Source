extends ItemEffect

func effect():
	Modifiers.coins_activated = true
	sfx.stream = SFX_ACTIVATE
	sfx.play()
