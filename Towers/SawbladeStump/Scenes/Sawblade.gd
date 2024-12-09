extends AreaOfEffect

var damage := 10.0
var frame := 0

onready var sprite : Sprite = $Sprite

func _ready():
	animate_frame()

func animate_frame():
	frame += 1
	sprite.position = Vector2(0.5, 0.5)
	sprite.rotation_degrees = 0
	sprite.flip_h = false
	sprite.flip_v = false
	if frame == 1:
		sprite.flip_v = true
	elif frame == 2:
		sprite.position.x = -0.5
		sprite.rotation_degrees = 90
	elif frame == 3:
		sprite.position.x = -0.5
		sprite.rotation_degrees = 90
		sprite.flip_h = true
	elif frame == 4:
		frame = 0
	
	var timer := get_tree().create_timer(0.1)
	timer.connect("timeout", self, "animate_frame")

# Override
func on_env_collision(collision: Dictionary, velocity: Vector2) -> void:
	position -= velocity
	direction = direction.bounce(collision["normal"])

func aoe_effect(target):
	if target.has_method("take_damage"):
		target.take_damage(damage * time_between_hits, direction)
	elif target.has_method("reflect"):
		var new_dir := get_angle_to(target.global_position + target.reflect_pos)
		direction = Vector2(cos(new_dir), sin(new_dir)).rotated(PI)
