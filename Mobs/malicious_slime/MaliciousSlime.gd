extends Mob

const CASH_REWARD := 6.0
const MIN_HOP := 10.0
const MAX_HOP := 17.0
const HOP_SPEED := 2.0
const ZOMBIE_HOP_SPEED := 1.5

var old_pos := Vector2.ZERO
var new_pos := Vector2.ZERO
var is_hopping := false
var is_zombie := false
var lerp_time := 0.0
var just_transformed := false # don't transform twice in a row

onready var animator : AnimationPlayer = $Animator

func _ready():
	set_flash_sprite($Sprite)
	animator.play("idle")

func _process(delta):
	if is_hopping and stun < 1.0:
		if is_zombie:
			lerp_time += delta * ZOMBIE_HOP_SPEED
		else:
			lerp_time += delta * HOP_SPEED
		if freeze > 1.0:
			lerp_time -= delta
		
		position = old_pos.linear_interpolate(new_pos, lerp_time)

func hop() -> void:
	path_offset = Vector2(rand_range(-path_deviation, path_deviation),
		 rand_range(-path_deviation, path_deviation))
	old_pos = position
	
	new_pos = path_move(rand_range(MIN_HOP, MAX_HOP), false, true)
	if (new_pos.x - old_pos.x) < -0.01:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	is_hopping = true


func _on_animation_finished(anim_name : String) -> void:
	match anim_name:
		"idle":
			if stun > 1.0:
				animator.play("idle")
				return
			var rand := randf()
			if rand < 0.9 or just_transformed:
				animator.play("hop")
			else:
				animator.play("transform")
			just_transformed = false
		"zombie_idle":
			if stun > 1.0:
				animator.play("zombie_idle")
				return
			var rand := randf()
			if rand < 0.8 or just_transformed:
				animator.play("zombie_hop")
			else:
				animator.play("reverse_transform")
			just_transformed = false
		"transform":
			animator.play("zombie_idle")
			is_zombie = true
			just_transformed = true
			$ZombieCollision.disabled = false
			$CollisionShape2D.disabled = true
		"reverse_transform":
			animator.play("idle")
			is_zombie = false
			just_transformed = true
			$ZombieCollision.disabled = true
			$CollisionShape2D.disabled = false
		"hop":
			animator.play("idle")
			if abs(path.get_baked_length() - path.get_closest_offset(position)) < 4.0:
				on_path_complete()
		"zombie_hop":
			animator.play("zombie_idle")
			if abs(path.get_baked_length() - path.get_closest_offset(position)) < 4.0:
				on_path_complete()

func on_death(direction):
	flash_material.set_shader_param("flash", 1.0)
	var timer : SceneTreeTimer = get_tree().create_timer(0.06, false)
	timer.connect("timeout", self, "_die")

func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_REWARD, 18)
	queue_free()

# Override
func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
	if is_zombie:
		.take_damage(damage / 2.0, direction, effect)
	else:
		.take_damage(damage, direction, effect)

func stop_hop():
	is_hopping = false
	lerp_time = 0.0
