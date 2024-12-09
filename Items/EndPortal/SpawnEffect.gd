extends Sprite

var frame_num = 0

func _ready():
	_animate()

func _animate():
	frame = frame_num % 2
	if frame_num < 5:
		frame_num += 1
		var timer := get_tree().create_timer(0.1, false)
		timer.connect("timeout", self, "_animate")
	else:
		queue_free()
