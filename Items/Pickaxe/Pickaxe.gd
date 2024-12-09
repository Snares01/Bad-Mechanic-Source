extends ItemEffect

func effect():
	SignalBus.emit_signal("destroy_area", get_player().global_position + Vector2(0, -8), 3)
	
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()
