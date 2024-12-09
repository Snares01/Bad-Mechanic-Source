extends ItemEffect

const TELEPORT_EFFECT := preload("res://Items/EndPortal/TeleportEffect.tscn")
const SPAWN_EFFECT := preload("res://Items/EndPortal/SpawnEffect.tscn")

var player : KinematicBody2D
var cam : Camera2D
var move_cam := false
var target_pos := Vector2.ZERO

func effect():
	cam = get_game_camera()
	player = get_player()
	var teleport_effect: Sprite = TELEPORT_EFFECT.instance()
	player.get_parent().add_child(teleport_effect)
	teleport_effect.position = player.position + Vector2(0, -8)
	player.hide()
	player.disabled = true
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	
	if get_parent().name == "GameController":
		var path: Curve2D = get_parent().mob_path
		target_pos = path.interpolate_baked(path.get_baked_length())
		cam.track_position(cam.current_pos)
		cam.disable_mouse_offset = true
		move_cam = true
	player.position = target_pos
	
	var timer := get_tree().create_timer(0.2, false)
	timer.connect("timeout", self , "_move_cam")

#func _move_player():

func _move_cam():
	if move_cam:
		cam.slow_track_player()
		cam.disable_mouse_offset = false
	
	var timer := get_tree().create_timer(0.4, false)
	timer.connect("timeout", self , "_teleport_player")

func _teleport_player():
	var instance := SPAWN_EFFECT.instance()
	player.get_parent().add_child(instance)
	instance.position = player.position + Vector2(0, -8)
	
	var timer := get_tree().create_timer(0.5, false)
	timer.connect("timeout", self , "_spawn")

func _spawn():
	player.show()
	player.disabled = false
	player.flash_material.set_shader_param("flash", 1.0)
	
	var timer := get_tree().create_timer(0.1, false)
	timer.connect("timeout", self , "_finish")

func _finish():
	player.flash_material.set_shader_param("flash", 0.0)
	queue_free()
