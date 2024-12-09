extends Node

enum bus {
	MASTER = 0,
	UI = 1,
	SFX = 2,
	MUSIC = 3,
}
const SETTINGS_FILE_PATH := "user://game-settings.ini"
const ACTIONS := [
	"move_up", "move_down", "move_left", "move_right",
	"use_item_1", "use_item_2", "use_item_3"
]
const DEFAULT_KEYS := [
	KEY_W, KEY_S, KEY_A, KEY_D, KEY_1, KEY_2, KEY_3
]

var config := ConfigFile.new()


func _ready():
	if config.load(SETTINGS_FILE_PATH) != OK:
		print("Creating default config file")
		set_defaults()
	apply_config_settings()


func set_defaults():
	config.set_value("video", "window-mode", 1) # Windowed
	config.set_value("video", "vsync", 1) # VSync on
	config.set_value("video", "max-fps", 0) # Unlimited fps (overwritten by vsync)
	
	config.set_value("audio", "master-volume", 1.0) # Scale of 0.0 - 1.0
	config.set_value("audio", "ui-volume", 1.0)
	config.set_value("audio", "sfx-volume", 1.0)
	config.set_value("audio", "music-volume", 1.0)
	
	config.set_value("gameplay", "move_up", KEY_W)
	config.set_value("gameplay", "move_down", KEY_S)
	config.set_value("gameplay", "move_left", KEY_A)
	config.set_value("gameplay", "move_right", KEY_D)
	config.set_value("gameplay", "use_item_1", KEY_1)
	config.set_value("gameplay", "use_item_2", KEY_2)
	config.set_value("gameplay", "use_item_3", KEY_3) 
	config.set_value("gameplay", "hints", 1)
	config.set_value("gameplay", "skip-intro", 0)
	
	config.save(SETTINGS_FILE_PATH)

func apply_config_settings():
	# Keybinds
	for action in ACTIONS:
		var event := InputEventKey.new()
		event.scancode = config.get_value("gameplay", action, DEFAULT_KEYS[ACTIONS.find(action)])
		
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
	
	# Window mode
	var window_mode: int = config.get_value("video", "window-mode", 1)
	if window_mode == 0: # Fullscreen
		OS.window_fullscreen = true
	elif window_mode == 1: # Windowed
		OS.window_fullscreen = false
		OS.window_borderless = false
		OS.window_maximized = false
	else: # Borderless
		OS.window_fullscreen = false
		OS.window_borderless = true
		# window will act like its fullscreen without this stupid shit
		OS.window_position = Vector2.ZERO
		var screen_size := OS.get_screen_size()
		OS.window_size = Vector2(screen_size.x, screen_size.y + 1)
	
	OS.vsync_enabled = config.get_value("video", "vsync", 1)
	Engine.target_fps = config.get_value("video", "max-fps", 0)
	# Audio
	AudioServer.set_bus_volume_db(bus.MASTER, linear2db(config.get_value("audio", "master-volume", 1.0)))
	AudioServer.set_bus_volume_db(bus.UI, linear2db(config.get_value("audio", "ui-volume", 1.0)))
	AudioServer.set_bus_volume_db(bus.SFX, linear2db(config.get_value("audio", "sfx-volume", 1.0)))
	AudioServer.set_bus_volume_db(bus.MUSIC, linear2db(config.get_value("audio", "music-volume", 1.0)))
	# Gameplay options
	Modifiers.skip_intro = config.get_value("gameplay", "skip-intro", 0)
	Modifiers.hints = config.get_value("gameplay", "hints", 1)

