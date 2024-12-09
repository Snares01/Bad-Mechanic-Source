extends PanelContainer

signal exited()

enum bus {
	MASTER = 0,
	UI = 1,
	SFX = 2,
	MUSIC = 3,
}
const CLICK_SOUND = preload("res://Interface/Assets/ButtonClick.tscn")
var hit_sfx : AudioStreamPlayer
var escape_to_close := false
# Video
onready var frame_slider : HSlider = get_node("%FrameSlider")
onready var frame_label : Label = get_node("%FrameLabel")
onready var window_option : OptionButton = get_node("%WindowOption")
onready var monitor_option : OptionButton = get_node("%MonitorOption")
onready var v_sync : CheckBox = get_node("%VSync")
# Audio
onready var master_slider : HSlider = get_node("%MasterSlider")
onready var master_label : Label = get_node("%MasterLabel")
onready var ui_slider : HSlider = get_node("%UISlider")
onready var ui_label : Label = get_node("%UILabel")
onready var effect_slider : HSlider = get_node("%EffectSlider")
onready var effect_label : Label = get_node("%EffectLabel")
onready var music_slider : HSlider = get_node("%MusicSlider")
onready var music_label : Label = get_node("%MusicLabel")
# Gameplay
onready var hints : CheckBox = get_node("%Hints")
onready var intro : CheckBox = get_node("%Intro")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	hide()
	_update_menu()
	var instance = CLICK_SOUND.instance()
	add_child(instance)
	hit_sfx = instance

func make_sound():
	hit_sfx.play()

func _process(delta):
	if escape_to_close and Input.is_action_just_pressed("pause"):
		_on_Exit_pressed()
	
	if monitor_option.get_item_count() != OS.get_screen_count():
		monitor_option.clear()
		for i in OS.get_screen_count():
			monitor_option.add_item(str(i+1), i)
		if window_option.selected in [0, 2] and OS.get_screen_count() > 1:
			monitor_option.show()
			get_node("%MonitorLabel").show()
		else:
			monitor_option.hide()
			get_node("%MonitorLabel").hide()



func apply_settings():
	# Window / monitor options
	if window_option.selected != -1:
		match window_option.selected:
			0: # Fullscreen
				OS.window_fullscreen = true
				if OS.get_screen_count() > 1:
					OS.current_screen = monitor_option.selected
			1: # Windowed
				OS.window_fullscreen = false
				OS.window_borderless = false
				OS.window_maximized = false
			2: # Borderless
				OS.window_fullscreen = false
				OS.window_borderless = true
				# window will act like its fullscreen without this stupid shit
				OS.window_position = Vector2.ZERO
				if OS.get_screen_count() > 1:
					OS.current_screen = monitor_option.selected
				var screen_size := OS.get_screen_size()
				OS.window_size = Vector2(screen_size.x, screen_size.y + 1)
	# VSync & framerate
	OS.vsync_enabled = v_sync.pressed
	Engine.target_fps = 0
	if not OS.vsync_enabled:
		if frame_slider.value != 241:
			Engine.target_fps = frame_slider.value
	else:
		frame_label.text = "Max Framerate:\n" + str(OS.get_screen_refresh_rate()) + " (VSync)"
	# Gameplay
	Modifiers.hints = hints.pressed
	Modifiers.skip_intro = intro.pressed
	
	update_config_file() # < key bindings saved here


func update_config_file():
	var config: ConfigFile = ConfigFileHandler.config
	
	config.set_value("video", "window-mode", window_option.selected) # Windowed
	config.set_value("video", "vsync", OS.vsync_enabled) # VSync on
	config.set_value("video", "max-fps", Engine.target_fps) # Unlimited fps (overwritten by vsync)
	
	config.set_value("audio", "master-volume", master_slider.value) # Scale of 0.0 - 1.0
	config.set_value("audio", "ui-volume", ui_slider.value)
	config.set_value("audio", "sfx-volume", effect_slider.value)
	config.set_value("audio", "music-volume", music_slider.value)
	
	config.set_value("gameplay", "move_up", InputMap.get_action_list("move_up")[0].scancode)
	config.set_value("gameplay", "move_down", InputMap.get_action_list("move_down")[0].scancode)
	config.set_value("gameplay", "move_left", InputMap.get_action_list("move_left")[0].scancode)
	config.set_value("gameplay", "move_right", InputMap.get_action_list("move_right")[0].scancode)
	config.set_value("gameplay", "use_item_1", InputMap.get_action_list("use_item_1")[0].scancode)
	config.set_value("gameplay", "use_item_2", InputMap.get_action_list("use_item_2")[0].scancode)
	config.set_value("gameplay", "use_item_3", InputMap.get_action_list("use_item_3")[0].scancode) 
	config.set_value("gameplay", "hints", int(hints.pressed))
	config.set_value("gameplay", "skip-intro", int(intro.pressed))
	
	config.save(ConfigFileHandler.SETTINGS_FILE_PATH)

# Update settings to current values
func _update_menu():
	# Window options
	if OS.window_fullscreen:
		window_option.select(0)
	elif OS.window_borderless:
		window_option.select(2)
	else:
		window_option.select(1)
	
	# Monitor select
	monitor_option.hide()
	get_node("%MonitorLabel").hide()
	for i in OS.get_screen_count():
		monitor_option.add_item(str(i+1), i)
	if window_option.selected != 1 and OS.get_screen_count() > 1:
		monitor_option.show()
		get_node("%MonitorLabel").show()
	
	# Vsync & framerate
	v_sync.pressed = OS.vsync_enabled
	if v_sync.pressed:
		frame_slider.hide()
		frame_label.text = "Max Framerate:\n" + str(OS.get_screen_refresh_rate()) + " (VSync)"
	else:
		frame_slider.show()
		if Engine.target_fps == 0:
			frame_slider.value = 241 # "unlimited"
		else:
			frame_slider.value = Engine.target_fps
	
	# Volume sliders
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.MASTER))
	master_label.text = _float2percent(master_slider.value)
	ui_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.UI))
	ui_label.text = _float2percent(ui_slider.value)
	effect_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.SFX))
	effect_label.text = _float2percent(effect_slider.value)
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(bus.MUSIC))
	music_label.text = _float2percent(music_slider.value)
	
	# Gameplay options
	hints.pressed = Modifiers.hints
	intro.pressed = Modifiers.skip_intro

func _float2percent(floatie: float) -> String:
	return String(round(floatie * 100)) + "%"


func _on_Exit_pressed():
	hide()
	emit_signal("exited")
	_update_menu()


func _on_FrameSlider_changed(value: float):
	if value < 241:
		frame_label.text = "Max Framerate:\n" + str(value)
	else:
		frame_label.text = "Max Framerate:\nUnlimited"


func _on_WindowOption_item_selected(index: int):
	make_sound()
	if index != 1 and OS.get_screen_count() > 1:
		monitor_option.show()
		get_node("%MonitorLabel").show()
	else:
		monitor_option.hide()
		get_node("%MonitorLabel").hide()


func _on_VSync_toggled(button_pressed: bool):
	if button_pressed:
		frame_slider.hide()
		frame_label.text = "Max Framerate:\n" + str(OS.get_screen_refresh_rate()) + " (VSync)"
	else:
		frame_slider.show()
		if frame_slider.value == 241:
			frame_label.text = "Max Framerate:\nUnlimited"
		else:
			frame_label.text = "Max Framerate:\n" + str(frame_slider.value)

# Volume sliders apply settings immediately
func _on_MasterSlider_value_changed(value: float):
	AudioServer.set_bus_volume_db(bus.MASTER, linear2db(value))
	master_label.text = _float2percent(value)

func _on_UISlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus.UI, linear2db(value))
	ui_label.text = _float2percent(value)

func _on_EffectSlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus.SFX, linear2db(value))
	effect_label.text = _float2percent(value)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus.MUSIC, linear2db(value))
	music_label.text = _float2percent(value)
