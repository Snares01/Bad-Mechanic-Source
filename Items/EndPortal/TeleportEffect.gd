extends Sprite

func _ready():
	var timer := get_tree().create_timer(0.1, false)
	timer.connect("timeout", self, "_next_frame")

func _next_frame():
	frame = 1
	var timer := get_tree().create_timer(0.1, false)
	timer.connect("timeout", self, "_die")

func _die():
	queue_free()
