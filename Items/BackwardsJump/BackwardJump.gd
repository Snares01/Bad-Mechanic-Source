extends ItemEffect

func effect():
	var player := get_player()
	player.backwards_long_jump()
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()
