extends KinematicBody2D
class_name Boss

signal intro_end()
signal boss_death()

const HIT_SOUND := preload("res://Mobs/!Classes/HitSound.tscn")
const MAX_FLASH := 1.5
const MIN_FLASH := 0.1
const FLASH_MULTIPLIER := 1.5
const FLASH_BRIGHTNESS := 0.32
const FLASH_DECAY_SPEED := 1.5
const BOOSTED_DECAY_SPEED := 15.0
const POISON_TICK_RATE := 0.5

export var max_health := 1000.0
export var boss_name := "Scary Guy"
export var freeze_resist := 10.0
export var poison_resist := 2.0
export var stun_resist := 25.0

var health := 1000.0
var flash := 0.0
var hit_sfx : AudioStreamPlayer2D
var hit_sfx_reserve := 0 # Holds extra hit sounds to avoid spamming them
# perhaps add path_ref for bosses to use
var path_ref : Curve2D
var player_ref : KinematicBody2D
var flash_material : ShaderMaterial
var is_dead := false
# status effects
var freeze := 0.0
var poison := 0.0
var stun := 0.0

onready var animator : AnimationPlayer = $Animator
onready var sprite : Sprite = $Sprite
onready var poison_timer := Timer.new()

func _ready():
	collision_layer = 0
	collision_mask = 1
	pause_mode = Node.PAUSE_MODE_PROCESS
	health = max_health
	set_process(false) # Intro start/end is partially handled by GameController
	set_physics_process(false)
	animator.play("intro")
	var instance := HIT_SOUND.instance()
	add_child(instance)
	hit_sfx = instance
	if position.x < 0.0:
		sprite.flip_h = true
	# poison timer
	add_child(poison_timer)
	poison_timer.connect("timeout", self, "poison")
	poison_timer.one_shot = true


func _process(delta):
	# Handle hit-flash
	if flash > 0 and not is_dead:
		if flash > MIN_FLASH:
			flash = max(0, flash - (delta * BOOSTED_DECAY_SPEED * flash))
		else:
			flash = max(0, flash - (delta * FLASH_DECAY_SPEED))
		if flash > 0:
			flash_material.set_shader_param("flash", min(1.0, FLASH_BRIGHTNESS + ((flash * FLASH_MULTIPLIER) - MIN_FLASH)))
		else:
			flash_material.set_shader_param("flash", 0.0)
	# Handle hit sound reserve
	if hit_sfx_reserve > 0 and hit_sfx.get_playback_position() > 0.06:
		hit_sfx.play()
		hit_sfx_reserve -= 1
	# Handle status effects
	modulate = Color(1.0, 1.0, 1.0)
	if freeze > 0.0:
		freeze = max(0.0, freeze - (delta * freeze_resist))
		modulate.r -= 0.25
		modulate.g -= 0.25
		modulate.b += 0.25
	if poison > 0.0:
		modulate.r -= 0.25
		modulate.g += 0.25
		modulate.b -= 0.25
	if stun > 0.0:
		stun = max(0.0, stun - (delta * stun_resist))
		modulate.r -= 0.25
		modulate.g -= 0.25
		modulate.b -= 0.25


func end_intro():
	set_process(true)
	set_physics_process(true)
	pause_mode = Node.PAUSE_MODE_STOP
	emit_signal("intro_end")


func set_flash_sprite(sprite_node : Sprite):
	flash_material = sprite_node.material
	flash_material.set_shader_param("spritesheet_size", Vector2(sprite_node.hframes, sprite_node.vframes))


func take_damage(damage: float, direction: Vector2, effect := Bullet.effect.NONE):
	# handle status effect
	match effect:
		Bullet.effect.FREEZE:
			freeze(abs(damage))
		Bullet.effect.POISON:
			poison(abs(damage))
		Bullet.effect.STUN:
			stun(abs(damage))
	if damage < 0.0: # status effect only
		return
	health -= damage
	# hit sound
	if hit_sfx.playing and hit_sfx.get_playback_position() <= 0.05:
		if hit_sfx_reserve < 3:
			hit_sfx_reserve += 1
	else:
		hit_sfx.play()
	# hit flash
	if (flash < MIN_FLASH):
		flash += MIN_FLASH + (damage / max_health)
	else:
		flash += damage / max_health
	# on death
	if health <= 0.0 and is_dead == false: 
		flash_material.set_shader_param("flash", 0.0)
		is_dead = true
		on_death(direction)
		emit_signal("boss_death")

func freeze(amount : float):
	freeze += amount

func poison(amount := poison):
	take_damage(amount / poison_resist, Vector2.DOWN)
	if poison < amount:
		poison = amount
	poison *= 0.8
	if poison > 0.5 and poison_timer.is_stopped():
		poison_timer.start(POISON_TICK_RATE)
	elif poison <= 0.5:
		poison = 0.0

func stun(amount : float):
	stun += amount

# Virtual function
func on_death(direction : Vector2):
	pass
