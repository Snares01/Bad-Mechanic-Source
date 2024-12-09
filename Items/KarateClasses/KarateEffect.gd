extends ItemEffect

func effect():
	var player := get_player()
	player.karate_dash()
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()
