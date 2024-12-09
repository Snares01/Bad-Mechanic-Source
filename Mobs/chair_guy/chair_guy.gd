extends Mob

const SPEED_VAR := 2.5
const CASH_REWARD := 10
const DEATH_SPIN_SPEED := 2.5
const DEATH_ANIM_LENGTH := 0.9
const MIN_SPIN_SPEED := 0.5
const MAX_SPIN_SPEED := 2.0
const SPIN_FRICTION := 0.8 # Loss of speed per second
const DAMAGE_SPIN_MULTIPLIER := 5.0 # Effects how much spin is added by damage
const DAMAGE_FLIP_CHANCE := 0.1 # % chance that a hit will reverse spin direction
const DEATH_COLLIDE_OFFSET := Vector2(0, -5)

export var death_collide_shape : CircleShape2D

var anim := "" # Determines how the businessman looks
var spin_speed := 1.0 # The speed of the spinning anim, wont go below MIN_SPIN_SPEED
var death_collision := false # true if mob has hit a wall during death anim

onready var animator : AnimationPlayer = $Animator

func _ready():
	set_flash_sprite($Sprite)
	base_speed += rand_range(-SPEED_VAR, SPEED_VAR)
	death_knockback_velocity = 25.0
	death_knockback_decay = 0.25
	
	var rand := randf()
	if rand > 0.5:
		anim = "flip" # I couldnt get the regular animation to play backwards. idk
	anim += str(SignalBus.rng.randi_range(1, 5))
	animator.play(anim, -1, spin_speed)


func _process(delta):
	if is_dead:
		# death collision logic (thank u gdquest)
		if death_collision == false:
			var query := Physics2DShapeQueryParameters.new()
			query.set_shape(death_collide_shape)
			query.collide_with_bodies = true
			query.collision_layer = 1
			query.transform = global_transform.translated(DEATH_COLLIDE_OFFSET)
			
			var result := get_world_2d().direct_space_state.intersect_shape(query, 1)
			if result:
				death_collision = true
				death_knockback = death_knockback.rotated(PI)
		return
	if spin_speed > MIN_SPIN_SPEED:
		spin_speed -= SPIN_FRICTION * delta
		
	var new_pos := path_move(speed * delta, false)
	if path_progress > path.get_baked_length():
		on_path_complete()
	position = new_pos
	animator.playback_speed = spin_speed


func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
	.take_damage(damage, direction, effect)
	if is_dead or damage < 0.0:
		return
	spin_speed = min(MAX_SPIN_SPEED, spin_speed + ((damage / max_health) * DAMAGE_SPIN_MULTIPLIER))
	# Flip animation
	var rand := randf()
	if rand < DAMAGE_FLIP_CHANCE:
		if anim.begins_with("flip"):
			anim = anim.lstrip("flip")
		else:
			anim = "flip" + anim
		var anim_length := animator.current_animation_length
		var anim_pos := animator.current_animation_position
		animator.play(anim, -1, spin_speed)
		anim_pos = ((anim_length/2) + ((anim_length/2) - anim_pos))
		animator.seek(anim_pos, true)


func on_death(direction : Vector2):
	animator.playback_speed = DEATH_SPIN_SPEED
	var timer := get_tree().create_timer(DEATH_ANIM_LENGTH, false)
	timer.connect("timeout", self, "_death_flash_begin")

func _death_flash_begin():
	flash_material.set_shader_param("flash", 1.0)
	var timer := get_tree().create_timer(0.08)
	timer.connect("timeout", self, "_die")

func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_REWARD, 36)
	queue_free()
