extends ItemEffect

func effect():
	var player := get_player()
	player.freeze = 0.0
	player.stun = 0.0
	player.poison = 0.0
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()
