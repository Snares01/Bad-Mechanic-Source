extends Furniture

var walky := false

onready var guy := $Guy

func _ready():
	guy.frame = SignalBus.rng.randi_range(0, 4) * 2
	squirm()
	if randf() < 0.5:
		flip()

func squirm():
	if walky:
		guy.frame -= 1
		walky = false
	else:
		guy.frame += 1
		walky = true
	
	var timer := get_tree().create_timer(0.5)
	timer.connect("timeout", self, "squirm")

func flip():
	$Sprite.flip_h = true
	$Guy.flip_h = false
	$Guy.position.x = 10
	$CollisionShape2D.position.x = -10
