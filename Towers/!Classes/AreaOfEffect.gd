extends Area2D
class_name AreaOfEffect

export var time_between_hits := 0.1 # In seconds
# Defined by tower with create_bullet or in _ready()
var direction := Vector2.RIGHT
var speed := 50.0
var lifespan := 10.0 # -1 for infinite lifespan
var speed_decay := 0.0 # Loss of speed (per second)
var disabled := false
var time := 1.0

onready var hitbox_shape : Shape2D = $CollisionShape2D.shape

func _ready():
	collision_layer = 0
	collision_mask = 2+16
	hide()


func _process(delta):
	if disabled:
		time = 0.0
		return
	speed -= speed_decay * delta
	var velocity : Vector2 = direction * speed * delta
	position += velocity
	var collision := get_env_collision()
	if not collision.empty():
		on_env_collision(collision, velocity)
	# Hits
	time -= delta
	if time < 0:
		_on_aoe_timeout()
		time = time_between_hits
	# Lifespan stuff
	if lifespan == -1:
		return
	lifespan -= delta
	if lifespan < 0:
		queue_free()

func get_env_collision() -> Dictionary:
	var query := Physics2DShapeQueryParameters.new()
	var direct_space_state := get_world_2d().direct_space_state
	query.set_shape(hitbox_shape)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_layer = 1
	query.transform = global_transform
	
	var result := direct_space_state.get_rest_info(query)
	return result

func on_env_collision(collision: Dictionary, velocity : Vector2) -> void:
	queue_free()

func _on_aoe_timeout():
	for area in get_overlapping_areas():
		aoe_effect(area)
	for body in get_overlapping_bodies():
		aoe_effect(body)

# Func used by towers for spawning bullets. Inaccuracy is in radians
func create_aoe(pos: Vector2, dir, spd: float, hit_rate := 0.1, life := 10.0, decay := 0.0) -> void:
	position = pos
	var new_dir : float
	if dir is float:
		new_dir = dir
	else: # dir is Vector2 aim position
		new_dir = get_angle_to(dir)
	direction = Vector2(cos(new_dir), sin(new_dir))
	speed = spd
	time_between_hits = hit_rate
	time = time_between_hits
	lifespan = life
	speed_decay = decay
	show()

# Virtual function
func aoe_effect(target):
	pass

func wall_collision():
	pass
