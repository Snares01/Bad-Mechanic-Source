extends Sprite

const INTRO_RAND := 2.0
const DEATH_ANIM_LENGTH := 0.66
const CASH_REWARD := 8
const DEATH_KNOCKBACK_SPEED := 10.0

export var intro_path_lerp := 0.0 setget intro_path_set
export var intro_litter_lerp := 0.0 setget intro_litter_set

var path_ref : Curve2D # Given by TEO
var litter : Boss # Given by TEO
var litter_offset := Vector2.ZERO # Given by TEO
var intro_path_target := Vector2.ZERO
var is_dead := false

onready var animator: AnimationPlayer = $Animator

func _ready():
	material.set_shader_param("spritesheet_size", Vector2(hframes, vframes))
	pause_mode = PAUSE_MODE_PROCESS
	intro_path_target = path_ref.interpolate_baked(30.0) + Vector2(
		rand_range(-INTRO_RAND, INTRO_RAND), rand_range(-INTRO_RAND, INTRO_RAND)
	)
	if intro_path_target.x < 0:
		flip_h = true
	animator.play("intro")
	litter.connect("begin_walk", self, "begin_walk")
	litter.connect("lift", self, "lift")
	litter.connect("die", self, "die")

func _process(delta):
	if is_dead:
		position += litter_offset.normalized() * DEATH_KNOCKBACK_SPEED * delta
	elif animator.current_animation == "walk":
		position = litter.position
		flip_h = litter.sprite.flip_h
		if flip_h:
			position += Vector2(-litter_offset.x, litter_offset.y)
		else:
			position += litter_offset

func intro_path_set(lerp_amount: float):
	if is_inside_tree():
		position = lerp(Vector2.ZERO, intro_path_target, lerp_amount)

func intro_litter_set(lerp_amount: float):
	if is_inside_tree():
		var target_pos := litter.position
		if litter.sprite.flip_h:
			target_pos += Vector2(-litter_offset.x, litter_offset.y)
		else:
			target_pos += litter_offset
		position = lerp(intro_path_target, target_pos, lerp_amount)
		if lerp_amount == 1:
			return
		if target_pos.x < position.x:
			flip_h = true
		else:
			flip_h = false

# called by TEO
func begin_walk():
	animator.play("walk")

func lift():
	frame = 2

func die():
	is_dead = true
	if litter_offset.x < 0:
		rotation_degrees = -90
	else:
		rotation_degrees = 90
		
	var timer : SceneTreeTimer = get_tree().create_timer(DEATH_ANIM_LENGTH, false)
	timer.connect("timeout", self, "_flash_begin")

func _flash_begin():
	material.set_shader_param("flash", 1.0)
	var timer : SceneTreeTimer = get_tree().create_timer(0.05)
	timer.connect("timeout", self, "_die_for_real")

func _die_for_real():
	get_parent().create_cash(global_position + Vector2(0, -4), CASH_REWARD, 23)
	queue_free()
