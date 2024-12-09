extends ItemEffect


func effect():
	Modifiers.collect_radius_multiplier *= 1.6
	sfx.stream = SFX_ACTIVATE
	sfx.play()
