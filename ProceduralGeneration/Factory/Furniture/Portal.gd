extends Furniture

signal spawned(success)

const BG_MUSIC := preload("res://Audio/Music/present_doom.ogg")

var spawned := false
var is_it_portal_time := false
var is_portal_activated := false
var player_ref: KinematicBody2D = null

func _ready():
	get_parent().get_parent().connect("level_end", self, "_on_level_end")

# Play animation where player activates portal
func trigger_portal(player):
	MusicController.fade_out()
	is_portal_activated = true
	$AnimationPlayer.play("activate")
	get_parent().get_parent().get_node("LevelEndTrigger").activate()
	$ActivateSound.play()
	player_ref = player
	player_ref.disable()


func _on_level_end():
	$PortalTrigger.monitoring = true

# Override
func check_destruction(center_pos: Vector2, _size: int):
	return

# Override
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
		spawned = true
		emit_signal("spawned", true)
	else:
		spawned = false
		emit_signal("spawned", false)


func _on_area_entered(area):
	if is_portal_activated:
		return
	if area.get_parent().has_method("load_hat"): # stupid way to check if its the player
		trigger_portal(area.get_parent())


func _on_activate_animation_finished(anim_name):
	MusicController.fade_in(BG_MUSIC)
	player_ref.enable()
	get_parent().get_parent().get_node("UILayer/MarginContainer").show()
	var portal_dialogue = get_parent().get_parent().get_node("UILayer/MarginContainer/PostPortalDialogue")  # Programming is my passion
	portal_dialogue.start()
	portal_dialogue.connect("finished", self, "_spawn_demons")

func _spawn_demons():
	get_parent().get_parent().get_node("UILayer/MarginContainer").hide()
	get_parent().get_parent().spawn_demon_portal()
