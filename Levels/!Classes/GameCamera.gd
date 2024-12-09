extends Camera2D

const MOUSE_OFFSET_SIZE := 0.025 # Represents a percentage of the window's size
const FOLLOW_SPEED := 5.0
const CAMERA_SHAKE := 12.5
const PLAYER_SPR_OFFSET := Vector2(0.0, 7.0)


var target_zoom := 1.0
var mouse_offset := Vector2.ZERO
var current_pos := Vector2.ZERO
var target_pos := Vector2.ZERO # Not used when targetting player
var targeting_player := false
var slow_targeting := false
var zoom_active := false
var player_ref
var disable_mouse_offset := false


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	target_zoom = 0.9
	zoom = Vector2(target_zoom, target_zoom)


func _process(delta):
	if targeting_player:
		current_pos = player_ref.global_position + mouse_offset + PLAYER_SPR_OFFSET
		if player_ref.flash > 0 and not get_tree().paused: # Screen shake
			global_position = (current_pos + 
			Vector2(randf() - 0.5, randf() - 0.5).normalized() * (player_ref.flash * CAMERA_SHAKE))
		else:
			global_position = current_pos
	else:
		var follow_speed := FOLLOW_SPEED
		if slow_targeting:
			target_pos = player_ref.global_position + PLAYER_SPR_OFFSET
			follow_speed *= 1.5
			if current_pos.distance_to(target_pos) < 2.0:
				track_player(player_ref)
		current_pos = current_pos.linear_interpolate(target_pos, delta * follow_speed)
		if disable_mouse_offset:
			global_position = current_pos
		else:
			global_position = current_pos + mouse_offset
	
	if zoom_active:
		if abs(zoom.x - target_zoom) < (delta*2): # snap if close enough
			target_zoom = zoom.x
			zoom_active = false
		else:
			zoom.x = move_toward(zoom.x, target_zoom, delta)
			zoom.y = zoom.x


func _input(event):
	if not event is InputEventMouseMotion:
		return
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var window_size : Vector2 = get_viewport_rect().size
	mouse_pos /= window_size
	mouse_pos -= Vector2(0.5, 0.5)
	mouse_offset = mouse_pos * (MOUSE_OFFSET_SIZE * window_size)

func track_position(pos : Vector2):
	target_pos = pos
	targeting_player = false
	slow_targeting = false

func track_player(player):
	player_ref = player
	targeting_player = true
	slow_targeting = false

func change_zoom(amount : float):
	zoom_active = true
	target_zoom = amount

func slow_track_player(): # Moves towards position, then locks to player
	slow_targeting = true
	targeting_player = false
