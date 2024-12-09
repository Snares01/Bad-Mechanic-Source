extends Control


func _ready():
	SignalBus.reset_progress()
	get_tree().change_scene("res://Interface/Shop/Shop.tscn")
