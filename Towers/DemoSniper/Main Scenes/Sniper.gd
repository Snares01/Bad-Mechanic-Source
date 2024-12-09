extends Tower

const ray_offset = Vector2(0, -11)
const max_ray_length := 500
enum state {
	IDLE = 0,
	AIM = 1,
	SHOOT = 2,
}

const BASE_DAMAGE := 95.0
const BASE_RANGE := 90.0

var damage := BASE_DAMAGE
var shoot_speed := 0.8 # speed of animation
export var ray_state = 0 # 0: idle, 1: aim, 2: pew pew

var target : Mob = null

onready var ray := $Ray
onready var ray_cast : RayCast2D = $RayCast
onready var space_state = get_world_2d().direct_space_state
onready var shoot_sfx = get_node("Shoot_SFX")


func _ready():
	$Animator.play("Idle")

func update_stats(): # Max 20
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 9.0)
	sight_range = BASE_RANGE


func _physics_process(delta):
	if ray_state == state.IDLE:
		return
	elif ray_state == state.AIM:
		if is_instance_valid(target):
			ray_cast.cast_to = ray_cast.global_position.direction_to(target.global_position + target.aim_offset) * max_ray_length
		ray_cast.force_raycast_update()
		if ray_cast.is_colliding():
			ray.set_point_position(1, ray.to_local(ray_cast.get_collision_point()))
		else:
			ray.set_point_position(1, ray_cast.cast_to)
		
	elif ray_state == state.SHOOT:
		if ray_cast.is_colliding():
			ray.set_point_position(1, ray.to_local(ray_cast.get_collision_point()))
			if is_instance_valid(ray_cast.get_collider()) and ray_cast.get_collider().has_method("take_damage"):
				ray_cast.get_collider().take_damage(damage * delta, ray_cast.cast_to.normalized())
		else:
			ray.set_point_position(1, ray_cast.cast_to)


func change_state(new_state : int):
	if new_state == state.IDLE:
		ray_state = state.IDLE
		$Animator.play("Idle")
		ray.hide()
	elif new_state == state.AIM:
		ray_state = state.AIM
		$Animator.play("Shoot", -1, shoot_speed)
		ray.set_point_position(1, Vector2.ZERO)
		ray.show()
	elif new_state == state.SHOOT:
		shoot_sfx.play()
		ray_state = state.SHOOT
		ray.set_point_position(1, Vector2.ZERO)


func _on_animation_finished(anim_name):
	target = select_target_mob(0, ray_offset, "strong")
	if target != null:
		change_state(state.AIM)
	else:
		change_state(state.IDLE)
