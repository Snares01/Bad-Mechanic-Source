extends ItemEffect

const CRONCHES := [
	preload("res://Items/Sandwiches/Cronch/crunch1.wav"),
	preload("res://Items/Sandwiches/Cronch/crunch2.wav"),
	preload("res://Items/Sandwiches/Cronch/crunch3.wav"),
	preload("res://Items/Sandwiches/Cronch/crunch4.wav"),
]
export var heal_per_bite := 20.0

func effect():
	SignalBus.change_health(-heal_per_bite)
	sfx.stream = CRONCHES[SignalBus.rng.randi_range(0, CRONCHES.size() - 1)]
	sfx.play()
