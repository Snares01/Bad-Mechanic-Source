extends StaticBody2D
class_name Furniture

export var collision_check_shape : Shape2D
export var destruction_size := 25.0 # How far destroy_area will affect

var map_rect : Rect2 # set by LevelGenerator
var bottom_map_ref : TileMap
var place_automatically := true


func _ready():
	SignalBus.connect("destroy_area", self, "check_destruction")
	if place_automatically:
		hide()
		spawn()
	else:
		show()

func check_destruction(center_pos: Vector2, _size: int):
	if global_position.distance_to(center_pos) < destruction_size:
		queue_free()

func spawn():
	# Look for random positions to spawn
	var rng := SignalBus.rng
	var valid_pos := Vector2.ZERO
	for i in 100:
		var pos_x : float = round(map_rect.position.x + (rng.randf() * map_rect.size.x))
		var pos_y : float = round(map_rect.position.y + (rng.randf() * map_rect.size.y))
		var rand_transform := Vector2(pos_x, pos_y)
		if is_position_valid(rand_transform):
			valid_pos = Vector2(pos_x, pos_y)
			break
	if valid_pos != Vector2.ZERO:
		global_position = valid_pos
		show()
	else:
		queue_free()

# Checks collisions with walls / path
func is_position_valid(collision_pos : Vector2) -> bool:
	# Check for collisions
	var query := Physics2DShapeQueryParameters.new()
	query.set_shape(collision_check_shape)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_layer = 5 # Env, NoBuild 5
	query.transform = Transform2D(0, collision_pos)
	var result := get_world_2d().direct_space_state.intersect_shape(query, 1)
	if result:
		return false
	# Ensure position is on floor
	var tile_check := bottom_map_ref.world_to_map(collision_pos)
	if bottom_map_ref.get_cellv(tile_check) == TileMap.INVALID_CELL:
		return false
	return true
