extends Sprite

var brightness := 0.8

func _process(delta):
	brightness -= delta
	modulate = Color(brightness, brightness, brightness)
	if brightness < 0.5:
		queue_free()
