extends Furniture

const EXPLOSION := preload("res://Towers/!Resources/Explosion.tscn")
const MAX_HEALTH := 3.0

var health = MAX_HEALTH

func take_damage(damage, direction, freeze := false):
	health -= damage
	if health <= 0:
		# Add slight delay for explosion chains
		var timer := get_tree().create_timer(0.1)
		timer.connect("timeout", self, "explode")

func explode():
	var instance := EXPLOSION.instance()
	instance.global_position = global_position + Vector2(0, -5)
	get_parent().add_child(instance)
	queue_free()

# Override
func check_destruction(center_pos: Vector2, _size: int):
	if global_position.distance_to(center_pos) < destruction_size:
		explode()
