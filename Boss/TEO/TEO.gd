extends Boss

signal begin_walk() # signals for carriers
signal lift()
signal die()

const MOVE_SPEED := 4.0
const FREEZE_MOVE_SPEED := 2.8
const BODYGUARD_MIN_SPAWN := 5.0
const BODYGUARD_MAX_SPAWN := 7.0
const CARRIER := preload("res://Boss/TEO/Carrier.tscn")
const TEO_MOB := preload("res://Boss/TEO/LittleCEO.tscn")
const BODYGUARD := preload("res://Mobs/Little Business/Variations/Bodyguard.tscn")

export var intro_anim_lerp := 0.0 setget intro_lerp_set
var spawn_offset := Vector2.ZERO
var carriers := []
var path_progress := 60.0
var intro_lifted := false

func _ready():
	set_flash_sprite($Sprite)
	position = path_ref.interpolate_baked(60.0)
	spawn_offset = -path_ref.interpolate_baked(50.0)
	$Sprite.offset = spawn_offset
	$Officer.offset = spawn_offset
	if position.x < 0.0:
		_flip_h(true)
	
	var timer := get_tree().create_timer(24.0, false)
	timer.connect("timeout", self, "_spawn_bodyguard")

func _process(delta):
	if not is_dead:
		if freeze > 1.0:
			path_progress += FREEZE_MOVE_SPEED * delta
		elif stun < 1.0:
			path_progress += MOVE_SPEED * delta
		var new_pos : Vector2 = path_ref.interpolate_baked(path_progress)
		if (new_pos.x - position.x) < 0 and sprite.flip_h or (new_pos.x - position.x) < -0.01:
			_flip_h(true)
		else:
			_flip_h(false)
		position = new_pos
		if path_progress > path_ref.get_baked_length():
			Modifiers.mobs_missed += 1
			SignalBus.change_health(SignalBus.health * 2, false)

func intro_lerp_set(lerp_amount: float):
	var spr: Sprite = get_node_or_null("Sprite")
	var spr2: Sprite = get_node_or_null("Officer")
	var new_offset : Vector2 = lerp(spawn_offset, Vector2(0, 3), lerp_amount)
	
	if intro_lifted and lerp_amount == 1:
		spr.offset = Vector2.ZERO
		spr2.offset = Vector2.ZERO
	elif spr:
		spr.offset = new_offset
		spr2.offset = new_offset


func _spawn_bodyguard():
	if is_dead:
		return
	
	var instance: Mob = BODYGUARD.instance()
	instance.path = path_ref
	instance.boss = self
	get_parent().add_child(instance)
	
	var timer := get_tree().create_timer(rand_range(BODYGUARD_MIN_SPAWN, BODYGUARD_MAX_SPAWN), false)
	timer.connect("timeout", self, "_spawn_bodyguard")

# called during intro anim
func spawn_carrier(offset: Vector2):
	var instance: Sprite = CARRIER.instance()
	instance.path_ref = path_ref
	instance.litter = self
	instance.litter_offset = offset
	get_parent().add_child(instance)
	#carriers.append(instance)

# Override
func end_intro():
	.end_intro()
	emit_signal("begin_walk")

# called by anim
func carrier_lift():
	intro_lifted = true
	emit_signal("lift")

func on_death(direction : Vector2):
	emit_signal("die")
	sprite.offset = Vector2(0, 3)
	$Officer.offset = Vector2(0, 3)
	$Hurtbox.monitorable = false
	var timer := get_tree().create_timer(1.0, false)
	timer.connect("timeout", self, "run_away")

func run_away():
	var instance: Mob = TEO_MOB.instance()
	instance.path = path_ref
	instance.path_progress = path_progress
	get_parent().add_child(instance)
	$Officer.hide()

func _flip_h(flip: bool):
	$Sprite.flip_h = flip
	$Officer.flip_h = flip
