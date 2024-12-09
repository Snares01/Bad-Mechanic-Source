extends Bullet

const REGIONS = [
	Rect2(0, 13, 4, 3),
	Rect2(0, 16, 4, 4),
	Rect2(0, 20, 4, 4),
]

onready var rng : RandomNumberGenerator = SignalBus.rng
var current_frame := 0

func flip_around():
	current_frame += 1
	if current_frame == REGIONS.size():
		current_frame = 0
	texture.region = REGIONS[current_frame]
	flip_h = rng.randi_range(0, 1)
	flip_v = rng.randi_range(0, 1)
