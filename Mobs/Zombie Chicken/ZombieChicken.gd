extends Mob

const CASH_AMOUNT := 4 # Cash rewarded on death
const MIN_HOP := 7.0
const MAX_HOP := 15.0
const MIN_WAIT := 0.25
const MAX_WAIT := 2.0
const HOP_SPEED := 2.0

export var egg : Resource
export var feather : Resource

onready var animator = $Animator

var is_hopping := false
var lerp_time := 0.0
var old_pos := Vector2.ZERO
var new_pos := Vector2.ZERO
var menu_mode := false # Main menu chicken 

func _ready():
	idle()
	set_flash_sprite($Sprite)
	death_knockback_velocity = 0.0


func hop():
	animator.play("Hop")
	path_offset = Vector2(rand_range(-path_deviation, path_deviation),
		 rand_range(-path_deviation, path_deviation))
	old_pos = position
	if freeze < 5.0:
		new_pos = path_move(rand_range(MIN_HOP, MAX_HOP), false, true)
	else:
		new_pos = path_move(rand_range(MIN_HOP / 2, MAX_HOP / 2), false, true)
	if (new_pos.x - old_pos.x) < -0.01:
		$Sprite.flip_h = true
		$Sprite.offset = h_flip_offset
	else:
		$Sprite.flip_h = false
		$Sprite.offset = Vector2(1, 0)
	is_hopping = true

# called by animation
func lay():
	var instance : Mob = egg.instance()
	instance.path = path
	instance.path_progress = path_progress
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.show()


func idle():
	animator.play("Idle", -1, rand_range(MIN_WAIT, MAX_WAIT))


func _process(delta):
	if is_hopping:
		lerp_time += delta * HOP_SPEED
		position = old_pos.linear_interpolate(new_pos, lerp_time)


func on_death(direction):
	flash_material.set_shader_param("flash", 1.0)
	var timer : SceneTreeTimer = get_tree().create_timer(0.1)
	timer.connect("timeout", self, "_die")
# Called by on_death
func _die():
	get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 25.0)
	for i in SignalBus.rng.randi_range(1, 3):
		var instance : Sprite = feather.instance()
		get_parent().add_child(instance)
		instance.floor_pos = Vector2(position.x + rand_range(-4, 2), position.y)
		instance.position = instance.floor_pos + Vector2(0, -instance.height)
		instance.show()
	queue_free()


func _on_animation_finished(anim_name : String) -> void:
	match anim_name:
		"Idle", "Peck":
			var rand := randf()
			if rand < 0.35 or stun > 0.0:
				idle()
			elif rand < 0.5:
				animator.play("Peck")
			elif rand < 0.503:
				animator.play("Lay")
			else:
				hop()
		"Hop":
			is_hopping = false
			lerp_time = 0
			if abs(path.get_baked_length() - path.get_closest_offset(position)) < 4.0:
				on_path_complete()
			idle()
		"Lay":
			idle()

func on_path_complete():
	if menu_mode:
		queue_free()
	else:
		.on_path_complete()
