extends MarginContainer

const HAT_SELECT := preload("res://Interface/Menus/HatSelect/HatSelect.tscn")

func _ready():
	MusicController.fade_out()


func _on_Play_pressed():
	SignalBus.reset_progress()
	get_tree().change_scene("res://Interface/Shop/Shop.tscn")


func _on_Options_pressed():
	get_tree().change_scene("res://Interface/Menus/Options.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Discord_pressed():
	OS.shell_open("https://discord.gg/xcsY5BCuTt")


func _on_Hats_pressed():
	var instance := HAT_SELECT.instance()
	instance.start_game_on_select = false
	instance.connect("selected", self, "on_hat_selected")
	add_child(instance)
	$VBox.hide()


func on_hat_selected():
	$VBox.show()
