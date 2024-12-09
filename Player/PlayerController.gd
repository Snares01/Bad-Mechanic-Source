extends KinematicBody2D
signal intro_end()

const KARATE_AFTER_IMAGE := preload("res://Items/KarateClasses/AfterEffect.tscn")
const BASE_SPEED := 45.0
const FLASH_LENGTH := 0.15
const INTRO_SPEED := 0.5
const POISON_TICK_RATE := 0.75
const MAX_STUN := 10.0
const DASH_SPEED := 60.0
const JUMP_SPEED := 100.0
const JUMP_SPEED_DECAY := 60.0

var spawn_pos := Vector2.ZERO
var flash := 0.0
var disabled := true
var speed := BASE_SPEED
var is_intro := true
var intro_lerp := 0.0
var damage_multiplier := 1.0
var has_hat := false
var hat_offset : Vector2
var hat_flip_offset : Vector2
var highlighted := false # for shop hints
var dash_dir := Vector2.ZERO # karate classes
var jump_force := JUMP_SPEED # Backwards long jump
# status effects
var freeze := 0.0
var poison := 0.0
var stun := 0.0
# items n shit
var cash_health_boost := false # Red Cape


export var small_hit_sfx : AudioStream
export var medium_hit_sfx : AudioStream
export var big_hit_sfx : AudioStream

onready var hat := $Hat
onready var sprite := $Sprite
onready var animator := $Animator
onready var flash_material : ShaderMaterial = $Sprite.material
onready var hit_sfx := $HitSFX
onready var step_sfx := $StepSFX
onready var poison_timer := Timer.new()

func _ready():
	animator.play("Idle")
	update()
	add_to_group("Player", true)
	SignalBus.connect("player_health_changed", self, "_on_health_changed")
	sprite.material.set_shader_param("spritesheet_size", Vector2($Sprite.hframes, $Sprite.vframes))
	sprite.position = Vector2(0.0, -8.0) # it wont let me set these values in the gui
	sprite.offset = Vector2(0.0, 0.0)
	# poison timer
	add_child(poison_timer)
	poison_timer.connect("timeout", self, "poison")
	poison_timer.one_shot = true

func _physics_process(delta):
	if is_intro:
		if spawn_pos == Vector2.ZERO:
			return
		intro_lerp += delta * INTRO_SPEED
		global_position = Vector2.ZERO.linear_interpolate(spawn_pos, intro_lerp)
		if intro_lerp >= 1:
			is_intro = false
			disabled = false
			emit_signal("intro_end")
	if SignalBus.is_player_dead or disabled:
		return
	var velocity := _get_input() * speed
	# handle freeze effect
	modulate = Color(1.0, 1.0, 1.0)
	if freeze > 0.0:
		freeze = clamp(freeze - (delta * 10.0), 0.0, 50.0)
		velocity *= 0.6
		modulate.r -= 0.33
		modulate.g -= 0.33
		modulate.b += 0.3
	if poison > 0.0:
		modulate.r -= 0.25
		modulate.g += 0.25
		modulate.b -= 0.25
	if stun > 0.0:
		stun = max(0.0, stun - (delta * 15.0))
		velocity = Vector2.ZERO
		modulate.r = max(0.3, modulate.r - 0.3)
		modulate.g = max(0.3, modulate.g - 0.3)
		modulate.b = max(0.3, modulate.b - 0.3)
	if highlighted:
		modulate = Color(2, 2, 2, 1)
	# movement / animation
	if animator.current_animation == "Dash":
		velocity = dash_dir * DASH_SPEED
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	if animator.current_animation == "Jump":
		velocity = dash_dir * jump_force
		jump_force -= delta * JUMP_SPEED_DECAY
		if velocity.x < 0:
			sprite.flip_h = false
		elif velocity.x > 0:
			sprite.flip_h = true
	
	if not animator.current_animation in ["Dash", "Jump"]:
		if velocity == Vector2.ZERO and animator.current_animation != "Idle":
			animator.stop(false)
			animator.play("Idle")
		elif velocity != Vector2.ZERO and animator.current_animation != "Run":
			animator.play("Run")
	
	move_and_slide(velocity / Engine.time_scale)
	animator.playback_speed = 1.0 / Engine.time_scale


func _process(delta):
	if (flash > 0):
		flash = max(0, flash - delta)
		if (flash > 0):
			flash_material.set_shader_param("flash", 1.0)
		else:
			flash_material.set_shader_param("flash", 0.0)
	if has_hat and sprite.frame < 6:
		hat.frame = sprite.frame
		#print("wtf" + str(randf()))
		if hat.flip_h != sprite.flip_h:
			hat.flip_h = sprite.flip_h
			if hat.flip_h:
				hat.position = hat_flip_offset
			else:
				hat.position = hat_offset
	elif has_hat and animator.current_animation in ["Dash", "Jump"]:
		if hat.flip_h:
			hat.position = hat_flip_offset + Vector2.RIGHT
		else:
			hat.position = hat_offset + Vector2.LEFT


func take_damage(dmg : float, _direction, effect := Bullet.effect.NONE):
	if animator.current_animation == "Dash" or not visible:
		return
	# handle status effect
	match effect:
		Bullet.effect.FREEZE:
			freeze += abs(dmg) * Modifiers.freeze_multiplier
		Bullet.effect.POISON:
			poison(abs(dmg))
		Bullet.effect.STUN:
			stun = min(stun + ((abs(dmg) / 2.0) * Modifiers.stun_multiplier), MAX_STUN)
	if dmg < 0.0: # status effect only
		return
	var damage := dmg * damage_multiplier
	SignalBus.change_health(damage)
	flash = FLASH_LENGTH
	# Play audio
	if hit_sfx.playing and hit_sfx.get_playback_position() < 0.033:
		return # Avoid spamming audio too quickly
	if damage < 1.0:
		hit_sfx.stream = small_hit_sfx
	elif damage < 10.0:
		hit_sfx.stream = medium_hit_sfx
	else:
		hit_sfx.stream = big_hit_sfx
	hit_sfx.play()

func poison(amount := poison):
	if amount == 0:
		return
	take_damage(amount / 2, Vector2.DOWN)
	if poison < amount:
		poison = amount
	poison *= Modifiers.poison_multiplier
	if poison > 2.5 and poison_timer.is_stopped():
		poison_timer.start(POISON_TICK_RATE)
	elif poison <= 2.5:
		poison = 0.0

func _on_health_changed(damage: float, shot: bool):
	if SignalBus.is_player_dead and shot:
		hat.hide()
		$Hurtbox.collision_layer = 0
		animator.play("Death")

# called by GameController
func play_intro() -> void:
	animator.play("Run", -1, 0.8)
	if spawn_pos.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

# called by GameController on spawn
func load_hat(new : HatInfo):
	new.player_effect(self)
	hat.texture = new.spr
	hat_offset = new.spr_offset
	hat_flip_offset = new.spr_flip_offset
	if sprite.flip_h:
		hat.position = hat_flip_offset
	else:
		hat.position = hat_offset
	hat.show()
	has_hat = true


func karate_dash():
	animator.play("Dash")
	dash_dir = _get_input()
	if dash_dir == Vector2.ZERO:
		if sprite.flip_h:
			dash_dir = Vector2.LEFT
		else:
			dash_dir = Vector2.RIGHT

func spawn_karate_effect():
	var instance: Sprite = KARATE_AFTER_IMAGE.instance()
	get_parent().add_child(instance)
	instance.flip_h = sprite.flip_h
	instance.global_position = global_position + sprite.position + Vector2.DOWN

func backwards_long_jump():
	animator.play("Jump")
	jump_force = JUMP_SPEED
	dash_dir = _get_input() * -1
	if dash_dir == Vector2.ZERO:
		if sprite.flip_h:
			dash_dir = Vector2.RIGHT
		else:
			dash_dir = Vector2.LEFT

func footstep():
	step_sfx.play()

func _get_input() -> Vector2:
	var move_dir = Vector2.ZERO
	move_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return move_dir.normalized()

# Called by TowerPreview
func show_range(size: float):
	$BuildRange.show_range(size)

# Called by LevelEndTrigger
func disable():
	disabled = true
	$Hurtbox.collision_layer = 0
	$Animator.play("Idle")

# Called by portal
func enable():
	disabled = false
	$Hurtbox.collision_layer = 16


func _on_PickupBox_area_entered(area):
	if area.has_method("pick_up"):
		area.pick_up()


func _on_animation_finished(anim_name: String):
	if anim_name == "Dash" or anim_name == "Jump":
		if hat.flip_h:
			hat.position = hat_flip_offset
		else:
			hat.position = hat_offset
		animator.play("Idle")

# Called by Red Cape
func drain_health():
	SignalBus.change_health(min(SignalBus.max_health / 100.0, 2.0))
	var timer: SceneTreeTimer
	if SignalBus.game_level > SignalBus.LEVEL_PROGRESSION.size():
		timer = get_tree().create_timer(14.0, false)
	else:
		timer = get_tree().create_timer(1.25, false)
	timer.connect("timeout", self, "drain_health")
