extends Furniture

onready var zombie := $Zomb

func _ready():
	flip_flop()
	if randf() < 0.5:
		just_flip_no_flop()


func flip_flop():
	if zombie.frame == 0:
		zombie.frame = 1
	else:
		zombie.frame = 0
	
	var timer := get_tree().create_timer(rand_range(0.3, 0.4))
	timer.connect("timeout", self, "flip_flop")

func just_flip_no_flop():
	$Sprite.flip_h = true
	$CollisionPolygon2D.scale.x = -1
	$Zomb.flip_h = true
	$Zomb.position.x *= -1
