extends Area2D
class_name Hurtbox

func _init():
	collision_layer = 16
	collision_mask = 0


func take_damage(damage, direction, effect := Bullet.effect.NONE):
	get_parent().take_damage(damage, direction, effect)
