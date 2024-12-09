extends HatInfo


func tower_card_effect(tower_card : VBoxContainer) -> void:
	tower_card.hard_mode = true

func game_controller_effect(game_controller : Node2D) -> void:
	game_controller.game_objects.hard_mode = true
