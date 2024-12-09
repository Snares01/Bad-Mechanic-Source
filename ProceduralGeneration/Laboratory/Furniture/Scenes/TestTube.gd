extends Furniture

const BABY_POS := Vector2(0, -14)

var t := 0.0
var float_speed := 1.0
onready var spr : Sprite = $Baby

func _ready():
	t = rand_range(-1.0, 1.0)
	float_speed += rand_range(-0.3, 0.3)

func _process(delta : float):
	t += delta * float_speed
	spr.position.y = BABY_POS.y + sin(t)
