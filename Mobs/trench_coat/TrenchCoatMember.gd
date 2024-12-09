extends "res://Mobs/Little Business/LittleMan.gd"

var spawn_pos : Vector2
var on_path := false

func _ready():
	position = spawn_pos

func path_move(distance : float, move := true, deviate := true) -> Vector2:
	if on_path:
		return .path_move(distance, move, deviate)
	
	var target_pos := path.interpolate_baked(path_progress) + path_offset
	if target_pos.x < position.x:
		sprite.flip_h = true
		sprite.offset = h_flip_offset
	else:
		sprite.flip_h = false
		sprite.offset = Vector2.ZERO
	
	position = position.move_toward(target_pos, distance)
	if position.distance_to(target_pos) < 1.0:
		on_path = true
	
	return Vector2.ZERO

