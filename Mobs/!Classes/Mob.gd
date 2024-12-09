extends Area2D
class_name Mob

const HIT_SOUND := preload("res://Mobs/!Classes/HitSound.tscn")
const MAX_FLASH := 2.5
const MIN_FLASH := 0.1
const FLASH_MULTIPLIER := 1.5
const FLASH_BRIGHTNESS := 0.36
const FLASH_DECAY_SPEED := 1.5
const BOOSTED_DECAY_SPEED := 15.0
const POISON_TICK_RATE := 0.66
const MAX_FREEZE := 300.0
const MIN_PATH_COMPLETE_DAMAGE := 5.0

export var max_health := 100.0
export var base_speed := 10.0 # Needs to be a class var for Tower class to use
export var path_deviation := 0.0
export var healthbar_width := 10.0
export var aim_offset := Vector2.ZERO
export var h_flip_offset := Vector2.ZERO # Use to center sprites while h_flip'd
export var freeze_resist := 10.0 # Higher value = recover from freeze faster
export var poison_resist := 2.0 # Higher value = less damage from poison
export var stun_resist := 10.0

var health := max_health
var speed := 10.0
var flash := 0.0
var hit_sfx : AudioStreamPlayer2D
var hit_sfx_reserve := 0 # Holds extra hit sounds to avoid spamming them
var path : Curve2D
var path_progress := 0.0
var path_offset := Vector2.ZERO
var flash_material : ShaderMaterial # Must be set by mobs in _ready() using set_flash_sprite()
var death_knockback := Vector2.ZERO
var death_knockback_velocity := 50.0
var death_knockback_decay := 5.0
var is_dead := false
var freeze := 0.0 # status effects
var poison := 0.0
var stun := 0.0

onready var sprite = $Sprite # Make one
onready var poison_timer := Timer.new()

func _ready():
	show()
	collision_layer = 18
	collision_mask = 0
	add_to_group("Mobs")
	speed = base_speed
	health = max_health
	path_move(0) # Go to beginning of path
	if path_deviation > 0:
		path_offset = Vector2(rand_range(-path_deviation, path_deviation),
		 rand_range(-path_deviation, path_deviation))
	# poison timer
	add_child(poison_timer)
	poison_timer.connect("timeout", self, "poison")
	poison_timer.one_shot = true
	# Create hit sound
	var instance = HIT_SOUND.instance()
	add_child(instance)
	hit_sfx = instance


func _process(delta):
	if is_dead and death_knockback_velocity > 0:
		death_knockback *= 1 - (delta * death_knockback_decay)
		position += death_knockback * delta
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
	# Handle effects
	modulate = Color(1.0, 1.0, 1.0)
	speed = base_speed
	if freeze > 0.0:
		freeze = min(max(0.0, freeze - (delta * freeze_resist)), MAX_FREEZE)
		speed = max(base_speed * 0.1, base_speed - (freeze / 10.0))
		if freeze < 10.0:
			modulate.r -= 0.2
			modulate.g -= 0.2
			modulate.b += 0.2
		else:
			modulate.r -= 0.4
			modulate.g -= 0.4
			modulate.b += 0.4
	if poison > 0.0:
		if poison < 3.0:
			modulate.r -= 0.2
			modulate.g += 0.2
			modulate.b -= 0.2
		else:
			modulate.r -= 0.4
			modulate.g += 0.4
			modulate.b -= 0.35
	if stun > 0.0:
		stun = max(0.0, stun - (delta * stun_resist))
		speed = 0.1
		modulate.r = max(0.25, modulate.r - 0.3)
		modulate.g = max(0.25, modulate.g - 0.3)
		modulate.b = max(0.25, modulate.b - 0.3)
	

# move: flips sprite, moves along path, checks for path completion
# deviate: add path deviation to returned pos
func path_move(distance : float, move := true, deviate := true) -> Vector2:
	path_progress += distance
	var new_pos : Vector2 = path.interpolate_baked(path_progress)
	if deviate:
		if path_progress < 50:
			new_pos += path_offset * (0.5 + (path_progress / 100))
		elif path.get_baked_length() < path_progress + 100:
			new_pos += path_offset * ((path.get_baked_length() - path_progress) / 100)
		else:
			new_pos += path_offset
	if move:
		if ((new_pos.x - position.x) < 0 and sprite.flip_h) or (new_pos.x - position.x) < -0.01:
			sprite.flip_h = true
			sprite.offset = h_flip_offset
		else:
			sprite.flip_h = false
			sprite.offset = Vector2.ZERO
		if path_progress > path.get_baked_length():
			on_path_complete()
		position = new_pos
	return new_pos

# Called by hitboxes
func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
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
	Modifiers.damage_dealt += damage
	health -= damage
	if hit_sfx.playing and hit_sfx.get_playback_position() <= 0.05:
		if hit_sfx_reserve < 3:
			hit_sfx_reserve += 1
	elif SignalBus.hit_sounds < 6:
		SignalBus.add_sound_effect()
		hit_sfx.play()
	# set hit-flash
	if (flash < MIN_FLASH):
		flash += MIN_FLASH + (damage / max_health)
	else:
		flash += damage / max_health
	# on death
	if health <= 0 and is_dead == false: 
		death_knockback = direction * death_knockback_velocity
		#SignalBus.change_xp(max_health * xp_multiplier)
		flash_material.set_shader_param("flash", 0.0)
		Modifiers.mobs_killed += 1
		on_death(direction)
		collision_layer = 0
		is_dead = true

# Status effect functions
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
	if stun > 1.0:
		stun += amount / 2.0
	else:
		stun += amount

# Set by mobs in _ready
func set_flash_sprite(sprite_node : Sprite):
	flash_material = sprite_node.material
	flash_material.set_shader_param("spritesheet_size", Vector2(sprite_node.hframes, sprite_node.vframes))

# Functions used by MobSelector
func select():
	flash_material.set_shader_param("line_color", Color(1.0, 1.0, 1.0, 1.0))

func hover():
	flash_material.set_shader_param("line_color", Color(1.0, 1.0, 1.0, 0.5))

func deselect():
	flash_material.set_shader_param("line_color", Color(1.0, 1.0, 1.0, 0.0))


func on_path_complete():
	Modifiers.mobs_missed += 1
	SignalBus.change_health(max(health / 2.0, MIN_PATH_COMPLETE_DAMAGE) * Modifiers.path_complete_damage_multiplier, false)
	if not SignalBus.is_player_dead:
		queue_free()

# Virtual function
func on_death(direction : Vector2):
	pass


