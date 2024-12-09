extends AreaOfEffect

var wave_freq := rand_range(2, 4)
var amplitude := rand_range(12, 25)
var amplitude_decay := rand_range(0.5, 2)
var wave_velocity := rand_range(0, 100)
var damage := 10.0 # damage per second

var can_collide := false

func _ready():
	var timer := get_tree().create_timer(0.15)
	timer.connect("timeout", self, "allow_collision")

func allow_collision():
	can_collide = true

func _physics_process(delta):
	wave_velocity += wave_freq * delta
	amplitude -= amplitude_decay * delta
	position += transform.y * cos(wave_velocity) * amplitude * delta

# Override
func on_env_collision(collision: Dictionary, velocity : Vector2) -> void:
	if can_collide:
		queue_free()

func aoe_effect(target):
	if target.has_method("take_damage"):
		target.take_damage(damage * time_between_hits, direction)
	elif target.has_method("reflect"):
		var new_dir := get_angle_to(target.global_position + target.reflect_pos)
		direction = Vector2(cos(new_dir), sin(new_dir)).rotated(PI)
