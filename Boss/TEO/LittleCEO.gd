extends "res://Mobs/Little Business/LittleMan.gd"

const CASH_REWARD := 80.0

var invincible := true

func _ready():
	var timer := get_tree().create_timer(0.8)
	timer.connect("timeout", self, "remove_invincibility")

func remove_invincibility():
	invincible = false

# Override
func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
	if not invincible:
		.take_damage(damage, direction, effect)

# Override
func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_REWARD, 25)
	queue_free()
