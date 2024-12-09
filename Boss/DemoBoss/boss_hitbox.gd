extends AreaOfEffect

export var damage := 30.0

func _ready():
	speed = 0
	lifespan = -1
	collision_mask = 16
	collision_layer = 0


func aoe_effect(target: Node):
	if target.get_parent().has_method("load_hat") and target.has_method("take_damage"): # if player
		target.take_damage(damage * time_between_hits, direction)

# Override
func on_env_collision(collision: Dictionary, velocity : Vector2) -> void:
	pass
