extends Tower

const BASE_RANGE := 46.0
const BASE_MOVE_SPEED := 20.0
const BULLET_SPEED := 36.0
const AIM_OFFSET := Vector2(0, -6)
const COLLIDE_OFFSET := Vector2(0, -3.5)

export var collide_shape : CircleShape2D
export var bullet : Resource
var move_dir := Vector2.RIGHT
var lifespan := 10.0 # set by factory
var damage := 0 # set by factory

onready var tracks : Sprite = $Tracks
onready var animator : AnimationPlayer = $Animator

func _ready():
	animate_track()
	animator.play("Idle")

func update_stats():
	sight_range = BASE_RANGE

func _process(delta):
	var velocity : Vector2 = move_dir * delta * BASE_MOVE_SPEED
	position += velocity
	
	if _check_collision():
		position -= velocity
		move_dir = move_dir.rotated(PI)
	
	lifespan -= delta
	if lifespan < 0:
		queue_free()
	
	if active and animator.current_animation == "Idle":
		animator.play("Shoot")

func shoot():
	var aim_pos = select_target_position(BULLET_SPEED, AIM_OFFSET)
	if aim_pos == Vector2.ZERO:
		return
	
	var instance : Bullet = bullet.instance()
	get_parent().add_child(instance)
	instance.create_bullet(position + AIM_OFFSET, aim_pos, BULLET_SPEED, damage, 0.025)

func check_mobs():
	if active:
		animator.play("Shoot")
	else:
		animator.play("Idle")

func animate_track():
	var current_frame := tracks.frame
	
	if current_frame == 3:
		tracks.frame = 0
	else:
		tracks.frame += 1
	
	var timer := get_tree().create_timer(0.1)
	timer.connect("timeout", self, "animate_track")

func _check_collision() -> bool:
	var query := Physics2DShapeQueryParameters.new()
	query.set_shape(collide_shape)
	query.collide_with_bodies = true
	query.collision_layer = 1
	query.transform = global_transform.translated(COLLIDE_OFFSET)
	
	var result := get_world_2d().direct_space_state.intersect_shape(query, 1)
	if result:
		return true
	return false


func _on_ReflectCollider_area_entered(area: Area2D):
	if area.has_method("reflect"):
		var new_dir := get_angle_to(area.global_position + area.reflect_pos)
		move_dir = Vector2(cos(new_dir), sin(new_dir)).rotated(PI)
