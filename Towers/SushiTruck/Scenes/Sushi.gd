extends Bullet


const REGIONS := [
	Rect2(0, 24, 5, 5),
	Rect2(5, 24, 5, 5),
	Rect2(0, 29, 5, 3),
	Rect2(5, 29, 5, 3),
]


func _ready():
	texture.region = REGIONS[SignalBus.rng.randi_range(0, 3)]
