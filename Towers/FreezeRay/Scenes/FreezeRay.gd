extends Tower

enum state {
	IDLE = 0,
	AIM = 1,
	SHOOT = 2,
}
const BASE_FREEZE := 240.0
const BASE_RANGE := 66.0
const AIM_OFFSET := Vector2(0, -11)
const MAX_RAY_LENGTH := 500.0
const AIM_MOVE_SPEED := 35.0
const RELOAD_TIME := 0.3

export var aim_ahead := 12.0 # how much area the laser sweeps covers
export var color_idle : Color
export var color_aim : Color
export var color_shoot : Color
export var sweep := 0.0 # controlled by anim
export(Bullet.effect) var bullet_effect
var damage := -BASE_FREEZE
var target : Mob
var aim_pos_front := Vector2.ZERO
var aim_pos_back := Vector2.ZERO
var reloaded := true

onready var animator : AnimationPlayer = $Animator
onready var ray_cast : RayCast2D = $Raycast
onready var ray_visual : Line2D = $Ray

func _ready():
	animator.play("idle")

func update_stats():
	damage = -(BASE_FREEZE + (TowerDict.stats[id]["Freeze"] * 12.0))
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 6.6)

func _physics_process(delta):
	match animator.current_animation:
		"idle":
			if active and reloaded:
				target = select_target_mob(-1, AIM_OFFSET)
				if target != null:
					ray_visual.default_color = color_aim
					aim_pos_front = Vector2.ZERO
					animator.play("aim")
		"aim":
			if is_instance_valid(target):
				var new_aim_pos_front := (target.path.interpolate_baked(target.path_progress + aim_ahead)
				  + target.path_offset + target.aim_offset)
				var new_aim_pos_back := (target.path.interpolate_baked(target.path_progress - aim_ahead)
				  + target.path_offset + target.aim_offset)
				if aim_pos_front != Vector2.ZERO: # aim movement
					aim_pos_front = aim_pos_front.move_toward(new_aim_pos_front, AIM_MOVE_SPEED * delta)
					aim_pos_back = aim_pos_back.move_toward(aim_pos_back, AIM_MOVE_SPEED * delta)
				else: # initial aim
					aim_pos_front = new_aim_pos_front
					aim_pos_back = new_aim_pos_back
				ray_cast.cast_to = ray_cast.global_position.direction_to(
				  aim_pos_front) * MAX_RAY_LENGTH
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				ray_visual.set_point_position(1, ray_visual.to_local(ray_cast.get_collision_point()))
			else:
				ray_visual.set_point_position(1, ray_cast.cast_to)
		"shoot":
			ray_cast.cast_to = aim_pos_front.slerp(aim_pos_back, sweep) * MAX_RAY_LENGTH
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				ray_visual.set_point_position(1, ray_visual.to_local(ray_cast.get_collision_point()))
				if ray_cast.get_collider().has_method("take_damage"):
					ray_cast.get_collider().take_damage(
					  damage * delta, ray_cast.cast_to.normalized(), bullet_effect)
			else:
				ray_visual.set_point_position(1, ray_cast.cast_to)

func reload():
	reloaded = true

func _on_animation_finished(anim_name : String):
	if anim_name == "aim":
		aim_pos_front = (global_position + AIM_OFFSET).direction_to(aim_pos_front)
		aim_pos_back = (global_position + AIM_OFFSET).direction_to(aim_pos_back)
		sweep = 0
		reloaded = false
		ray_visual.default_color = color_shoot
		animator.play("shoot")
	elif anim_name == "shoot":
		var timer := get_tree().create_timer(RELOAD_TIME)
		timer.connect("timeout", self, "reload")
		ray_visual.default_color = color_idle
		animator.play("idle")
