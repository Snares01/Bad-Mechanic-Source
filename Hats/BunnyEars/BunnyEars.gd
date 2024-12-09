extends HatInfo

func player_effect(player : KinematicBody2D):
	player.speed *= 1.33
	player.damage_multiplier = 1.1
