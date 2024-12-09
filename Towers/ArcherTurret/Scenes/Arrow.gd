extends Bullet

const SPR_STRAIGHT := Rect2(24, 0, 7, 3)
const SPR_TILTED := Rect2(24, 3, 7, 4)
const SPR_DIAGONAL := Rect2(26, 7, 6, 6)

# Override
func create_bullet(pos: Vector2, dir, spd: float, dmg: float, inaccuracy := 0.0, life := 10.0, decay := 0.0, status_eff := effect.NONE) -> void:
	.create_bullet(pos, dir, spd, dmg, inaccuracy, life, decay, status_eff)
	_set_sprite_direction()

# Override
func _physics_process(delta):
	var collision := get_collision()
	if collision:
		if collision.has_method("reflect"):
			rotation_degrees = 0
			var new_dir := get_angle_to(collision.global_position + collision.reflect_pos)
			direction = Vector2(cos(new_dir), sin(new_dir)).rotated(PI)
			_set_sprite_direction()
			return


func _set_sprite_direction():
	flip_h = false
	flip_v = false
	rotation_degrees = 0
	# set sprite according to direction
	if abs(direction.y) < 0.15: # Straight left/right
		texture.region = SPR_STRAIGHT
	elif abs(direction.x) < 0.15: # Straight up/down
		texture.region = SPR_STRAIGHT
		rotation_degrees = 90
	elif abs(direction.y) < 0.5: # left/right tilted up/down
		texture.region = SPR_TILTED
		if direction.x < 0:
			flip_h = true
		if direction.y < 0:
			flip_v = true
	elif abs(direction.x) < 0.5: # up/down tilted left/right
		texture.region = SPR_TILTED
		rotation_degrees = 90
		if direction.x > 0:
			flip_v = true
		if direction.y < 0:
			flip_h = true
	else: # diagonal
		texture.region = SPR_DIAGONAL
		if (direction.x > 0 and direction.y < 0) or (direction.x < 0 and direction.y > 0):
			flip_h = true
