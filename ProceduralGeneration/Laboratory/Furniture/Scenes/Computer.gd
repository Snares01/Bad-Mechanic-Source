extends Furniture

const MIN_BLINKY_TIME := 0.1
const MAX_BLINKY_TIME := 0.9

func _ready():
	var timer := get_tree().create_timer(MIN_BLINKY_TIME)
	timer.connect("timeout", self, "blinky")

func blinky():
	$Blinky.frame = SignalBus.rng.randi_range(0, 8)
	
	var timer := get_tree().create_timer(rand_range(MIN_BLINKY_TIME, MAX_BLINKY_TIME))
	timer.connect("timeout", self, "blinky")
