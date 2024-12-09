extends Area2D
class_name Tower

export var id : int = 0
export var range_offset := Vector2.ZERO # Sprite offset for range
var sight_range := 50.0 # Used by tower preview, set in update_stats()
var active := false
var preview := false # use if behavior needs to be different during shop preview

func _ready():
	update_stats()
	update_sight_range()
	SignalBus.connect("stat_update", self, "_on_update_stats")
	connect("area_entered", self, "_on_area_entered")
	collision_layer = 0
	collision_mask = 2


func _process(_delta):
	if active and get_overlapping_areas().empty():
		active = false
		deactivate()


func _on_area_entered(_area):
	if active == false:
		active = true
		activate()

# Virtual function
func activate():
	pass

# Virtual function
func deactivate():
	pass

# Called on stat upgrade, virtual function
func update_stats():
	pass


func _on_update_stats(idNum : int):
	if idNum == self.id:
		update_stats()
		update_sight_range()


func update_sight_range():
	$CollisionShape2D.shape.radius = sight_range # Has to be circle shape
	$CollisionShape2D.position = range_offset # Has to be named CollisionShape2D


func get_mobs(sortMethod : String = "first") -> Array:
	var mobs = get_overlapping_areas()
	
	if sortMethod == "close":
		mobs.sort_custom(self, "sort_close")
	elif sortMethod == "strong":
		mobs.sort_custom(self, "sort_strong")
	else:
		mobs.sort_custom(self, "sort_first")
	return mobs

# Main function for aiming; returns (0, 0) if target is not found
func select_target_position(aim_ahead := 0.0, origin := Vector2.ZERO, sort_method := "first") -> Vector2:
	var mob_list := get_mobs(sort_method)
	for mob in mob_list:
		if is_target_valid(mob, aim_ahead, origin):
			return get_aim_position(mob, aim_ahead, origin)
	return Vector2.ZERO

# Returns null if target is not found
func select_target_mob(aim_ahead := 0.0, origin := Vector2.ZERO, sort_method := "first") -> Mob:
	var mob_list := get_mobs(sort_method)
	for mob in mob_list:
		if is_target_valid(mob, aim_ahead, origin):
			return mob
	return null

func is_target_valid(enemy : Mob, aim_ahead := 0.0, origin := Vector2.ZERO) -> bool:
	if not is_instance_valid(enemy) or enemy.is_dead:
		return false
	
	var space_state := get_world_2d().direct_space_state
	var tar_pos := get_aim_position(enemy, aim_ahead, origin)
	var sight_test = space_state.intersect_ray(global_position+origin, tar_pos, [], 1)
	if sight_test:
		return false
	return true

# aim_ahead should be the speed of the projectile
func get_aim_position(enemy : Mob, aim_ahead := 0.0, origin := Vector2.ZERO) -> Vector2:
	var enemy_pos = enemy.global_position + enemy.aim_offset
	if aim_ahead <= 0.0 or enemy.speed == 0.0 or enemy.stun > 4.0:
		return enemy_pos
	
	origin += global_position
	var tar_distance = origin.distance_to(enemy_pos)
	var tar_offset = enemy.path_progress + (enemy.speed * (tar_distance / aim_ahead))
	return (enemy.path.interpolate_baked(tar_offset) +
	enemy.path_offset + enemy.aim_offset)

# Furthest along path
func sort_first(a : Mob, b : Mob) -> bool:
	if (a.path.get_closest_offset(a.position) >
	b.path.get_closest_offset(b.position)):
		return true
	return false

func sort_close(a : Mob, b : Mob) -> bool:
	if (global_position.distance_squared_to(a.global_position) <
	global_position.distance_squared_to(b.global_position)):
		return true
	return false

func sort_strong(a : Mob, b : Mob) -> bool:
	if a.health > b.health:
		return true
	return false
