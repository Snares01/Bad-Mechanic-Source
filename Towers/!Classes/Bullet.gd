extends Sprite
class_name Bullet

enum effect {
	NONE,
	FREEZE,
	POISON,
	STUN,
}
const REFLECT_SPEED_BOOST := 1.2

export var hitbox_shape : Shape2D
# Defined by tower with create_bullet
var direction := Vector2.RIGHT
var speed := 50.0
var damage := 10.0 # Damage per second if one_shot is false
var lifespan := 10.0
var speed_decay := 0.0 # Loss of speed (per second)
var initial_lifespan := 10.0
var status_effect : int = effect.NONE

func _ready():
	z_index = 5
	hide()


func _physics_process(delta):
	lifespan -= delta
	if lifespan < 0:
		queue_free()
	
	speed -= speed_decay * delta
	position += direction * speed * delta
	var collision := get_collision()
	if collision:
		if collision.has_method("take_damage"):
			collision.take_damage(damage, direction, status_effect)
		elif collision.has_method("reflect"):
			var new_dir := get_angle_to(collision.global_position + collision.reflect_pos)
			direction = Vector2(cos(new_dir), sin(new_dir)).rotated(PI)
			return
		elif (initial_lifespan - lifespan) < 0.15: # Ignore wall collisions on spawn
			return
		queue_free()


func get_collision() -> Object:
	var query := Physics2DShapeQueryParameters.new()
	var direct_space_state := get_world_2d().direct_space_state
	query.set_shape(hitbox_shape)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_layer = 17
	query.transform = global_transform
	
	var result := direct_space_state.intersect_shape(query, 1)
	if result.empty():
		return null
	return result[0]["collider"]

# Func used by towers for spawning bullets. Inaccuracy is in radians
# set damage to negative for status effect only
func create_bullet(pos: Vector2, dir, spd: float, dmg: float, inaccuracy := 0.0, life := 10.0, decay := 0.0, status_eff := effect.NONE) -> void:
	position = pos
	var new_dir : float
	if dir is float:
		new_dir = dir + rand_range(-inaccuracy, inaccuracy)
	else: # dir is Vector2 aim position
		new_dir = get_angle_to(dir) + rand_range(-inaccuracy, inaccuracy)
	direction = Vector2(cos(new_dir), sin(new_dir))
	speed = spd
	damage = dmg
	lifespan = life
	initial_lifespan = life
	speed_decay = decay
	status_effect = status_eff
	if SignalBus.current_hat != null:
		SignalBus.current_hat.bullet_effect(self)
	show()
