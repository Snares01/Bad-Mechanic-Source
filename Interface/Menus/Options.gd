extends MarginContainer

enum bus {
	MASTER = 0,
	UI = 1,
	SFX = 2,
	MUSIC = 3,
}

onready var master_slider := get_node("%MasterSlider")
onready var master_percent := get_node("%MasterPercent")
onready var music_slider := get_node("%MusicSlider")
onready var music_percent := get_node("%MusicPercent")
onready var UI_slider := get_node("%UISlider")
onready var UI_percent := get_node("%UIPercent")

onready var window_options := get_node("%WindowOptions")

func _ready():
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.MASTER))
	master_percent.text = _float2percent(master_slider.value)
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.MUSIC))
	music_percent.text = _float2percent(music_slider.value)
	UI_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.UI))
	UI_percent.text = _float2percent(UI_slider.value)
	if OS.window_fullscreen:
		window_options.select(1)
	elif OS.window_borderless:
		window_options.select(2)
	else:
		window_options.select(0)


func _on_Back_pressed():
	get_tree().change_scene("res://Interface/Menus/MainMenu.tscn")


func _float2percent(floatie: float) -> String:
	return String(round(floatie * 100)) + "%"


func _on_OptionButton_item_selected(index):
	match index:
		0: # Windowed
			OS.window_fullscreen = false
			OS.window_borderless = false
			OS.window_maximized = false
		1: # Fullscreen
			OS.window_fullscreen = true
		2: # Borderless
			OS.window_fullscreen = false
			OS.window_borderless = true
			# window will act like its fullscreen without this stupid shit
			OS.window_position = Vector2.ZERO
			var screen_size := OS.get_screen_size()
			OS.window_size = Vector2(screen_size.x, screen_size.y + 1)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_MasterSlider_value_changed(value : float):
	AudioServer.set_bus_volume_db(bus.MASTER, linear2db(value))
	master_percent.text = _float2percent(value)


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus.MUSIC, linear2db(value))
	music_percent.text = _float2percent(value)


func _on_UISlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus.UI, linear2db(value))
	UI_percent.text = _float2percent(value)
