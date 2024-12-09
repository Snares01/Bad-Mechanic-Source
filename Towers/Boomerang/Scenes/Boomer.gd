extends Bullet

const REGIONS := [
	Rect2(5, 14, 6, 6),
	Rect2(5, 20, 7, 3),
]
const SCHMOVE_SPEED := 0.075 # time between schmoves
var prev_speed := 0.0
var current_frame := 0

func _ready():
	var timer := get_tree().create_timer(SCHMOVE_SPEED)
	timer.connect("timeout", self, "schmove")

func _process(delta):
	if prev_speed > 0.0 and speed <= 0.0:
		$Hitbox.refresh()
	prev_speed = speed

func schmove():
	current_frame += 1
	if current_frame > 7:
		current_frame = 0
	texture.region = REGIONS[current_frame % 2]
	rotation_degrees = 90 * (current_frame / 2)
	offset.y = -(current_frame % 2)
	
	var timer := get_tree().create_timer(SCHMOVE_SPEED)
	timer.connect("timeout", self, "schmove")

# Override
func get_collision() -> Object:
	return null

# Override
func create_bullet(pos: Vector2, dir, spd: float, dmg: float, inaccuracy := 0.0, life := 10.0, decay := 0.0, status_eff := effect.NONE) -> void:
	.create_bullet(pos, dir, spd, dmg, inaccuracy, life, decay, status_eff)
	
	$Hitbox.damage = dmg
