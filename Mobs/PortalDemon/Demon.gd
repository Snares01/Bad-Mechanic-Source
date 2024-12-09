extends Boss

const MOVE_SPEED := 10.0
const LIFESPAN := 21.0
const LIFE_VARIATION := 2.0
const GUARD_POS_LIST := [Vector2(-50, 0), Vector2(50, 0), Vector2(0, -40), Vector2(0, 40), Vector2.ZERO]
const GUARD_DISTANCE := 50.0

var lifespan := 10.0
var long_target_offset := Vector2.ZERO

func _ready():
	set_flash_sprite(sprite)
	set_process(true)
	set_physics_process(true)
	pause_mode = Node.PAUSE_MODE_STOP
	lifespan = rand_range(LIFESPAN - LIFE_VARIATION, LIFESPAN + LIFE_VARIATION)
	animator.play("run")
	long_target_offset = GUARD_POS_LIST[SignalBus.rng.randi_range(0, GUARD_POS_LIST.size() - 1)]
	if position.direction_to(player_ref.position).x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _process(delta):
	if is_dead:
		return
	lifespan -= delta
	if lifespan < 0.0:
		on_death(Vector2.UP)
	# chase
	var dir: Vector2
	if position.distance_to(player_ref.position) > GUARD_DISTANCE:
		dir = position.direction_to(player_ref.position + long_target_offset)
	else:
		dir = position.direction_to(player_ref.position)
	if dir.x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	var velocity := dir * MOVE_SPEED
	velocity *= max(0.5, 1.0 - (freeze / 5.0))
	if stun == 0.0:
		move_and_slide(velocity)


func on_death(direction: Vector2):
	is_dead = true
	flash_material.set_shader_param("flash", 1.0)
	animator.play("die")
