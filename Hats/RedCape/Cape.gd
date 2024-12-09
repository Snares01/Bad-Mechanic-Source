extends HatInfo

var player_ref: KinematicBody2D

func player_effect(player : KinematicBody2D):
	player_ref = player
	var timer := player.get_tree().create_timer(5.0, false)
	timer.connect("timeout", self, "_apply_effect")

func game_controller_effect(game_controller : Node2D):
	game_controller.game_objects.cape_mode = true


func _apply_effect():
	if is_instance_valid(player_ref):
		player_ref.drain_health()
