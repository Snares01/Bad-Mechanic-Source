extends HatInfo


func player_effect(player : KinematicBody2D):
	SignalBus.change_cash(100)
	# increase size of player hitbox (bestest code ever coded)
	player.get_node("Hurtbox/CollisionShape2D").shape.height = 12.5
	player.get_node("Hurtbox/CollisionShape2D").position.y = -11
