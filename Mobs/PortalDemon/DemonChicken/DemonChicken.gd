extends Boss

const TELEPORT_EFFECT := preload("res://Items/EndPortal/TeleportEffect.tscn")
const MIN_LIFESPAN := 13.0
const MAX_LIFESPAN := 15.0
const MIN_HOP_WAIT := 0.4
const MAX_HOP_WAIT := 0.6
const HOP_SPEED := 50.0
const HOP_DIR_RAND := 1.0 # radians i think

var lifespan := 10.0
var is_hopping := false
var hop_dir := Vector2.UP

func _ready():
	set_flash_sprite(sprite)
	set_process(true)
	set_physics_process(true)
	pause_mode = Node.PAUSE_MODE_STOP
	lifespan = rand_range(MIN_LIFESPAN, MAX_LIFESPAN)
	
	if position.direction_to(player_ref.position).x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	var timer := get_tree().create_timer(MAX_HOP_WAIT, false)
	timer.connect("timeout", self, "start_hop")

func _process(delta):
	if is_dead:
		return
	lifespan -= delta
	if lifespan < 0.0:
		on_death(Vector2.UP)
	# chase
	if is_hopping:
		move_and_slide(hop_dir * HOP_SPEED)
		#position += hop_dir * HOP_SPEED * delta

func start_hop():
	is_hopping = true
	# set hop dir
	var hop_angle := position.angle_to_point(player_ref.position) + rand_range(-HOP_DIR_RAND, HOP_DIR_RAND)
	hop_dir = Vector2(cos(hop_angle), sin(hop_angle)).rotated(PI)
	if hop_dir.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	animator.play("hop")

func end_hop():
	is_hopping = false
	var timer := get_tree().create_timer(rand_range(MIN_HOP_WAIT, MAX_HOP_WAIT), false)
	timer.connect("timeout", self, "start_hop")

func on_death(direction : Vector2):
	flash_material.set_shader_param("flash", 1.0)
	var timer := get_tree().create_timer(0.1, false)
	timer.connect("timeout", self, "_die")

func _die():
	var teleport_effect: Sprite = TELEPORT_EFFECT.instance()
	get_parent().add_child(teleport_effect)
	teleport_effect.position = position + Vector2(0, -6)
	queue_free()
