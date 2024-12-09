extends Node2D

signal level_end()

const RUN_BACK_INTERMISSION := 5
const DEMON_PORTAL := preload("res://Mobs/PortalDemon/DemonPortal.tscn")
const LEVEL_HINT := preload("res://Levels/!Scenes/GameLevelHint.tscn")

var has_final_wave_ended := false
var has_boss_spawned := false
var has_boss_died := false
var intermission_time := 40 # seconds between waves
var path_length : float
var waves : WaveData
var mob_path : Curve2D
var player_ref
var portal_dialogue_called := false
var time_between_demons := 3.0

onready var game_objects = get_node("GameObjects")
onready var gui = $UILayer/GUI
onready var timer := Timer.new() # wave timer

func _ready():
	current_wave = 0
	current_step = 0
	gui.show()
	$UILayer.hide()
	if SignalBus.current_level is LevelSave:
		# Run back level
		mob_path = $LevelGenerator.import_mapsave(SignalBus.current_level.map_save)
		_load_level_save()
	else: # Main level
		mob_path = $LevelGenerator.import_mapdata(SignalBus.map_data)
		_load_level_data()
	$LevelEndTrigger.update_position($LevelGenerator.entrance_dir)
	path_length = mob_path.get_baked_length()
	SignalBus.connect("effect_activated", self, "_on_effect_activated")
	SignalBus.connect("player_health_changed", self, "_on_player_health_changed")
	SignalBus.connect("level_up", self, "_on_level_up")
	gui.connect("intermission_skipped", self, "_on_intermission_skipped")
	timer.connect("timeout", self, "_wave_update")
	add_child(timer)
	timer.one_shot = true
	timer.pause_mode = Node.PAUSE_MODE_STOP
	
	if SignalBus.current_hat != null:
		SignalBus.current_hat.game_controller_effect(self)

func _on_level_up(level: int):
	if level == 2 and Modifiers.hints and Modifiers.hint_tower_level:
		Modifiers.hint_tower_level = false
		var instance := LEVEL_HINT.instance()
		$UILayer.add_child(instance)
		gui.get_node("BuildUI").highlight_cards(true)
		instance.connect("closed", self, "_unhighlight_cards")

func _unhighlight_cards():
	gui.get_node("BuildUI").highlight_cards(false)

func _load_level_data():
	MusicController.fade_in(SignalBus.current_level.bg_music)
	waves = SignalBus.current_level.wave_data
	var spawn_pos = mob_path.interpolate_baked(60)
	yield(spawn_furniture($LevelGenerator.furniture_list), "completed")
	# start intro
	player_ref.spawn_pos = spawn_pos
	player_ref.play_intro()
	player_ref.connect("intro_end", self, "_on_intro_end")
	$Camera.track_position(spawn_pos + $Camera.PLAYER_SPR_OFFSET)

func _load_level_save():
	intermission_time = 2
	gui.get_node("WaveUI").hide()
	waves = SignalBus.current_level.wave_data
	var spawn_pos = mob_path.interpolate_baked(mob_path.get_baked_length())
	player_ref.position = spawn_pos
	player_ref.is_intro = false
	player_ref.disabled = false
	gui.emit_signal("intermission", intermission_time, 1)
	$Intermission.start(intermission_time)
	$UILayer.show()
	$Camera.track_player(player_ref)
	$Camera.change_zoom(1.0)
	gui.get_node("PauseMenu").pausing_disabled = false
	# demon portal
	var timer := get_tree().create_timer(3.0, false)
	timer.connect("timeout", self, "spawn_demon_portal")
	time_between_demons = SignalBus.current_level.demon_spawn_rate
	# spawn furniture & towers
	var furniture_list: Array = SignalBus.current_level.map_save.furniture
	var furniture_positions: Array = SignalBus.current_level.map_save.furniture_positions
	#yield(get_tree(), "physics_frame")
	for i in furniture_list.size():
		var furniture: Furniture = furniture_list[i].instance()
		furniture.place_automatically = false
		#$GameObjects.call_deferred("add_child", furniture)
		$GameObjects.add_child(furniture)
		furniture.global_position = furniture_positions[i]
	
	var tower_list: Array = SignalBus.current_level.map_save.towers
	var tower_positions: Array = SignalBus.current_level.map_save.tower_positions
	for i in tower_list.size():
		var tower: Tower = tower_list[i].instance()
		$GameObjects.add_child(tower)
		tower.global_position = tower_positions[i]

func spawn_demon_portal():
	var instance: Node2D = DEMON_PORTAL.instance()
	instance.player_ref = player_ref
	instance.spawn_pos_list = get_node("LevelGenerator/BottomMap").get_used_cells_by_id(0)
	game_objects.add_child(instance)
	
	var timer := get_tree().create_timer(time_between_demons, false)
	timer.connect("timeout", self, "spawn_demon_portal")

func _process(_delta):
	if has_boss_spawned:
		if has_boss_died and get_tree().get_nodes_in_group("Mobs").empty() and not $LevelEndTrigger.active:
			if SignalBus.game_level == SignalBus.LEVEL_PROGRESSION.size():
				if not portal_dialogue_called:
					var timer := get_tree().create_timer(2.2, false)
					timer.connect("timeout", self, "_trigger_portal_dialogue")
					portal_dialogue_called = true
			else:
				emit_signal("level_end")
				$LevelEndTrigger.activate()
		return
	if has_final_wave_ended and get_tree().get_nodes_in_group("Mobs").empty():
		if SignalBus.current_level.has_boss:
			spawn_boss()
		elif not $LevelEndTrigger.active:
			if SignalBus.game_level == SignalBus.LEVEL_PROGRESSION.size():
				if not portal_dialogue_called:
					var timer := get_tree().create_timer(2.2, false)
					timer.connect("timeout", self, "_trigger_portal_dialogue")
					portal_dialogue_called = true
			else:
				emit_signal("level_end")
				$LevelEndTrigger.activate()

func _trigger_portal_dialogue():
	add_child(load("res://Audio/Sound Effects/PhoneSFX.tscn").instance())
	
	var timer := get_tree().create_timer(0.5, false)
	timer.connect("timeout", self, "_start_dialogue_fr_fr")

func _start_dialogue_fr_fr():
	emit_signal("level_end")
	get_node("UILayer/MarginContainer").show()
	get_node("%PortalDialogue").start()
	get_node("%PortalDialogue").connect("finished", self, "_on_dialogue_finished")

func _on_dialogue_finished():
	get_node("UILayer/MarginContainer").hide()

func spawn_furniture(furniture_list : Array):
	yield(get_tree(), "physics_frame")
	
	if $LevelGenerator.data.portal != null:
		var portal : Furniture = furniture_list[0]
		$GameObjects.add_child(portal)
		if not portal.spawned:
			get_tree().change_scene("res://Levels/!Scenes/GameLevel.tscn")
			return
		furniture_list.pop_front()
	
	for instance in furniture_list:
		yield(get_tree(), "physics_frame")
		$GameObjects.add_child(instance)


func _on_intermission_skipped():
	$Intermission.stop()
	_on_Intermission_timeout()


func _on_effect_activated(effect : ItemEffect):
	add_child(effect)
	effect.effect()


var current_wave := 0
var current_step := 0 # "pieces" of each wave
var current_enemy := 0 # enemy of current wave step
func _wave_update():
	if current_wave >= waves.timeline.size():
		print("Tried to start invalid wave " + String(current_wave))
		has_final_wave_ended = true
		return
	
	var waveInfo = waves.timeline[current_wave]
	if current_step == waveInfo.size(): # Last step of wave
		current_wave += 1
		current_step = 0
		current_enemy = 0
		
		if current_wave == waves.timeline.size(): # Final wave finished
			print("Final enemy spawned")
			has_final_wave_ended = true
			return
		elif current_wave == (waves.timeline.size() - 1): # Final wave begin
			gui.emit_signal("intermission", intermission_time, -1)
		else: # Wave begin
			gui.emit_signal("intermission", intermission_time, current_wave + 1)
		$Intermission.start(intermission_time)
		
	elif current_enemy == waveInfo[current_step].y: # 
		timer.start(waveInfo[current_step].z)
		current_step += 1
		current_enemy = 0
	else:
		var instance : Mob = waves.mob_list[waveInfo[current_step].x].instance()
		instance.path = mob_path
		instance.hide()
		game_objects.add_child(instance)
		timer.start(waveInfo[current_step].z)
		current_enemy += 1


var mob_index : int
var wait_time : float
var time_decrease : float
func _boss_wave_update():
	if has_boss_died:
		return
	var instance : Mob = waves.mob_list[mob_index].instance()
	instance.path = mob_path
	instance.hide()
	game_objects.add_child(instance)
	wait_time = max(wait_time - time_decrease, 0.033)
	get_tree().create_timer(wait_time, false).connect("timeout", self, "_boss_wave_update")


func spawn_boss():
	has_boss_spawned = true
	var instance : Boss = SignalBus.current_level.boss_scene.instance()
	# Create instance
	instance.player_ref = player_ref
	instance.path_ref = mob_path
	instance.position = mob_path.interpolate_baked(0.0)
	game_objects.add_child(instance)
	instance.connect("boss_death", self, "_on_boss_death")
	instance.connect("intro_end", self, "_end_boss_intro")
	# Begin intro
	gui.get_node("BossUI").activate(instance)
	$Camera.track_position(instance.position)
	get_tree().paused = true

func _on_boss_death():
	has_boss_died = true

func _end_boss_intro():
	$Camera.track_player(player_ref)
	get_tree().paused = false
	# Start spawning mobs
	var spawn_info : Vector3 = SignalBus.current_level.boss_wave_spawns
	if spawn_info.x < 0:
		return
	mob_index = spawn_info.x
	wait_time = spawn_info.y
	time_decrease = spawn_info.z
	_boss_wave_update()


func _on_Intermission_timeout():
	timer.start(1) # Start spawning mobs


func _on_player_health_changed(health: float, shot: bool):
	if SignalBus.is_player_dead and not shot: # Death by path completion
		$Camera.track_position(mob_path.interpolate_baked(path_length))
		get_tree().paused = true

# Link Camera and GameObjects to player, begin intro
func _on_Player_ready():
	player_ref = get_node("GameObjects/Player")
	$GameObjects.player_ref = player_ref
	$UILayer/GUI/BuildUI.player_ref = player_ref
	$UILayer/GUI/PauseMenu.pausing_disabled = true
	if SignalBus.current_hat != null:
		player_ref.load_hat(SignalBus.current_hat)


func _on_intro_end():
	SignalBus.change_cash(SignalBus.current_level.starting_cash)
	gui.emit_signal("intermission", intermission_time, 1)
	$Intermission.start(intermission_time)
	$UILayer.show()
	$Camera.track_player(player_ref)
	$Camera.change_zoom(1.0)
	gui.get_node("PauseMenu").pausing_disabled = false

# Only called during run back
func _on_GameObjects_ready():
	pass # Replace with function body.
