extends Mob

const ANIM_SPEED_MODIFIER := 10.0
const HIT_MARKER := preload("res://Mobs/Shop Dummy/Damage Effect/DamageMarker.tscn")

var fast := true

func _ready():
	set_flash_sprite($Sprite)
	if fast:
		base_speed = rand_range(10.0, 22.0)
	else:
		base_speed = rand_range(5.5, 12.0)
		max_health *= 1.5
		health = max_health
	# set animation speed according to run speed
	$AnimationPlayer.play("move", -1, 1 + ((speed - ANIM_SPEED_MODIFIER) / ANIM_SPEED_MODIFIER))


func _process(delta):
	path_move(speed * delta)

# Override
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
	if hit_sfx.playing and hit_sfx.get_playback_position() <= 0.05:
		if hit_sfx_reserve < 3:
			hit_sfx_reserve += 1
	else:
		hit_sfx.play()
	# set hit-flash
	if (flash < MIN_FLASH):
		flash += MIN_FLASH + (damage / max_health)
	else:
		flash += damage / max_health
	# Create hit-marker
	var instance := HIT_MARKER.instance()
	get_parent().get_parent().add_child(instance)
	instance.position = position
	instance.update_effect(damage)

# Override
func on_path_complete():
	queue_free()
