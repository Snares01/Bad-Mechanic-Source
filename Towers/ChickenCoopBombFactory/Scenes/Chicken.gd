extends Tower

const EXPLOSION := preload("res://Towers/!Resources/Explosion.tscn")
const BASE_RANGE := 60.0
const LIFESPAN := 20.0
const BASE_HOP_SPEED := 42.0
const AIM_OFFSET := Vector2(0, -4)

var lifespan := LIFESPAN
var hop_speed := BASE_HOP_SPEED
var is_hopping := false
var hop_dir := Vector2.UP

func _ready():
	$Sprite.frame = SignalBus.rng.randi_range(0, 2)
	$Animator.play("hop")

func update_stats():
	hop_speed = BASE_HOP_SPEED + (TowerDict.stats[id]["Hop Speed"] * 4.0)
	sight_range = BASE_RANGE

func _process(delta):
	if is_hopping:
		position += hop_dir * hop_speed * delta
	lifespan -= delta
	if lifespan < 0:
		explode(0)

func start_hop():
	is_hopping = true
	var aim_pos := select_target_position(-1, AIM_OFFSET, "close")
	if aim_pos == Vector2.ZERO:
		hop_dir = hop_dir.rotated(PI)
	else:
		hop_dir = (global_position + AIM_OFFSET).direction_to(aim_pos)
	if hop_dir.x < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false

func end_hop():
	is_hopping = false

func explode(_arg):
	var instance := EXPLOSION.instance()
	instance.global_position = global_position + AIM_OFFSET
	get_parent().call_deferred("add_child", instance)
	queue_free()
