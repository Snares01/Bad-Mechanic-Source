extends Mob

const CASH_AMOUNT := 20.0
const SPAWN_OFFSET := Vector2(14, -5)
const MIN_LIFESPAN := 26.0
const MAX_LIFESPAN := 32.0
const TIME_BETWEEN_SPAWNS := 0.45
const PATH_PROGRESS_OFFSET := 35.0
const BUSINESS := preload("res://Mobs/trench_coat/TrenchCoatMember.tscn")

var lifespan := 15.0
var business_to_spawn := 3
var killed := false
onready var animator := $Animator

func _ready():
	set_flash_sprite($Sprite)
	lifespan = rand_range(MIN_LIFESPAN, MAX_LIFESPAN)
	animator.play("walk")
	death_knockback_velocity = 26
	death_knockback_decay = 3


func _process(delta):
	if animator.current_animation == "walk" and not killed:
		lifespan -= delta
		if lifespan < 0.0:
			animator.play("fall")
		path_move(speed * delta)



func _on_animation_finished(anim_name: String):
	if sprite.flip_h:
		death_knockback = Vector2(-1, 0) * death_knockback_velocity
	else:
		death_knockback = Vector2(1, 0) * death_knockback_velocity
	is_dead = true
	if killed:
		var timer := get_tree().create_timer(0.4, false)
		timer.connect("timeout", self, "death_flash")
	else:
		spawn_business()


func spawn_business():
	business_to_spawn -= 1
	var instance : Mob = BUSINESS.instance()
	instance.path = path
	instance.path_progress = path_progress + PATH_PROGRESS_OFFSET
	var spawn_offset := SPAWN_OFFSET
	if sprite.flip_h:
		spawn_offset *= -1
	instance.spawn_pos = global_position + spawn_offset
	get_parent().add_child(instance)
	
	if business_to_spawn > 0:
		var timer := get_tree().create_timer(TIME_BETWEEN_SPAWNS, false)
		timer.connect("timeout", self, "spawn_business")
	else:
		var timer := get_tree().create_timer(0.05, false)
		timer.connect("timeout", self, "death_flash")
		flash_material.set_shader_param("flash", 1.0)

func death_flash():
	var timer := get_tree().create_timer(0.05, false)
	timer.connect("timeout", self, "die_for_real")
	flash_material.set_shader_param("flash", 1.0)

func die_for_real():
	if killed:
		get_parent().create_cash(global_position + aim_offset, CASH_AMOUNT, 18)
	queue_free()

func on_death(direction : Vector2):
	if animator.current_animation == "walk":
		killed = true
		animator.play("fall")
		if direction.x < 0.0:
			sprite.flip_h = true
			sprite.offset = h_flip_offset
		else:
			sprite.flip_h = false
			sprite.offset = Vector2.ZERO
