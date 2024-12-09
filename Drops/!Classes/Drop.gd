extends Reference
class_name Drop

var type : int # Type of 
var position : Vector2
var spawn_position : Vector2
var rest_position : Vector2 # Position the drop will interpolate to on spawn
var lifespan : float
var collect_radius : float
var sprite_index : int
var current_state : int
var lerp_weight := 0.0
var show := true


func _init(id: int, pos: Vector2, offset: Vector2, life: float, collect: float, spr : int, state := 0):
	type = id
	position = pos
	spawn_position = pos
	rest_position = offset
	lifespan = life * rand_range(0.8, 1.2)
	collect_radius = collect
	sprite_index = spr
	current_state = state
