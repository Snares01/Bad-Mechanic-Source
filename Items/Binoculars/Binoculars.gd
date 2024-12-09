extends ItemEffect

func effect():
	Modifiers.build_radius_multiplier *= 1.5
	sfx.stream = SFX_ACTIVATE
	sfx.play()
