extends Boss

const JOG_SPEED := 22.0
const JOG_DAMAGE := 25.0
const JOG_TIME_BETWEEN_HITS := 0.20
const CHARGE_SPEED := 75.0
const CHARGE_INACCURACY := 0.0
const CHARGE_DAMAGE := 30.0
const CHARGE_TIME_BETWEEN_HITS := 1.0
enum state {
	IDLE,
	JOG,
	PRECHARGE,
	CHARGE,
}

export var intro_anim_lerp := 0.0 setget intro_lerp_set
var current_state : int = state.IDLE
var charge_dir : Vector2

onready var jog_hitbox : AreaOfEffect = $JogHitbox
onready var charge_hitbox : Hitbox = $ChargeHitbox

func _ready():
	set_flash_sprite(sprite)
	jog_hitbox.disabled = true
	position = path_ref.interpolate_baked(60.0)
	sprite.offset = -position
	if position.x < 0.0:
		$Sprite.flip_h = true

func intro_lerp_set(lerp_amount : float):
	var spr : Sprite = get_node_or_null("Sprite")
	if spr:
		spr.offset = lerp(-position, Vector2.ZERO, lerp_amount)

func _process(delta):
	match current_state:
		state.IDLE:
			pass
		state.JOG:
			var dir : Vector2 = position.direction_to(player_ref.position)
			if dir.x < 0.0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			var velocity := dir * JOG_SPEED
			velocity *= max(0.5, 1.0 - (freeze / 50.0))
			if stun == 0.0:
				move_and_slide(velocity)
		state.PRECHARGE:
			pass
		state.CHARGE:
			if stun == 0.0:
				var velocity := charge_dir * CHARGE_SPEED
				if freeze > 1.0:
					velocity *= 0.66
				move_and_slide(velocity)
			SignalBus.emit_signal("destroy_area", 
				global_position + Vector2(0, -16) + (charge_dir * 10), 3) # magical numbers :3


func change_state(new_state: int):
	if is_dead:
		return
	match new_state:
		state.IDLE:
			animator.play("idle")
			var timer := get_tree().create_timer(rand_range(0.5, 2.0))
			var rand := randf()
			var rand_state : int
			if rand < 0.444:
				rand_state = state.JOG
			else:
				rand_state = state.PRECHARGE
			timer.connect("timeout", self, "change_state", [rand_state])
			jog_hitbox.disabled = true
			charge_hitbox.disabled = true
		state.JOG:
			animator.play("jog")
			var timer := get_tree().create_timer(rand_range(4.0, 14.0))
			timer.connect("timeout", self, "change_state", [state.IDLE])
			jog_hitbox.disabled = false
			charge_hitbox.disabled = true
		state.PRECHARGE:
			animator.play("charge")
			if player_ref.position.x < position.x:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			jog_hitbox.disabled = true
			charge_hitbox.disabled = false
		state.CHARGE: # animation changes to this state
			var new_dir: float = get_angle_to(player_ref.position) + rand_range(-CHARGE_INACCURACY, CHARGE_INACCURACY)
			charge_dir = Vector2(cos(new_dir), sin(new_dir))
			charge_hitbox.refresh()
			charge_hitbox.disabled = false
			if charge_dir.x < 0.0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
	current_state = new_state


func set_offset(offset: Vector2) -> void:
	if sprite.flip_h:
		sprite.offset = Vector2(-offset.x, offset.y)
	else:
		sprite.offset = offset


func _on_animation_finished(anim_name: String):
	if anim_name == "intro":
		end_intro()
		change_state(state.IDLE)
	elif anim_name == "death":
		flash_material.set_shader_param("flash", 1.0)
		var timer := get_tree().create_timer(0.1)
		timer.connect("timeout", self, "_die_for_real")
	elif anim_name == "charge":
		change_state(state.IDLE)
		charge_hitbox.disabled = true

func _die_for_real():
	get_parent().create_cash(position, 45, 60)
	queue_free()


func on_death(direction : Vector2):
	set_process(false)
	animator.play("death")

