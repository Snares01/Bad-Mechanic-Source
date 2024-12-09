extends HatInfo


func game_controller_effect(game_controller : Node2D):
	game_controller.game_objects.drop_radius_multiplier *= 0.66

func bullet_effect(bullet : Bullet):
	bullet.damage *= 1.2
