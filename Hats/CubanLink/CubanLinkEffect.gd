extends HatInfo


func game_controller_effect(game_controller : Node2D):
	game_controller.intermission_time = 25
	game_controller.gui.get_node("WaveUI").skip_reward += 1
