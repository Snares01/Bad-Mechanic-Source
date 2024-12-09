extends ItemEffect

func effect():
	Modifiers.path_complete_damage_multiplier *= 0.8
	sfx.stream = SFX_ACTIVATE
	sfx.play()
