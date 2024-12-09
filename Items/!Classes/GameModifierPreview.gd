extends Sprite
class_name GameModifierPreview

const BASE_Y_VALUE := -50.0
const FLOAT_SPEED := 1.0
const FLOAT_RANGE := 5.0

var item_float := 0.0


func _process(delta):
	item_float += delta * FLOAT_SPEED
	position.y = BASE_Y_VALUE + (sin(item_float) * FLOAT_RANGE)
