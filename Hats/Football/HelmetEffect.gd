extends HatInfo


func player_effect(player : KinematicBody2D):
	player.damage_multiplier = 0.749076767
	player.get_node("BuildRange").build_radius *= 0.55
