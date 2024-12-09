extends AudioStreamPlayer2D


func _on_DestructionSound_finished():
	queue_free()
