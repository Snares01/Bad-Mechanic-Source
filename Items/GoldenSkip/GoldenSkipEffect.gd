extends ItemEffect

func effect():
	Modifiers.golden_skip = true
	sfx.stream = SFX_ACTIVATE
	sfx.play()
