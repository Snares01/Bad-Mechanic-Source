extends AudioStreamPlayer2D



func _on_PlaceSFX_finished():
	queue_free()
