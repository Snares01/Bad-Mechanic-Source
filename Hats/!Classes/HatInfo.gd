extends Node
class_name HatInfo

export var spr_offset : Vector2
export var spr_flip_offset : Vector2
export var spr : StreamTexture
export var end_screen_icon : StreamTexture

func player_effect(_player : KinematicBody2D) -> void:
	pass

func game_controller_effect(_game_controller : Node2D) -> void:
	pass

func bullet_effect(_bullet : Bullet) -> void:
	pass

func shop_effect(_shop_data : ShopData) -> void:
	pass

func tower_card_effect(_tower_card : VBoxContainer) -> void:
	pass
