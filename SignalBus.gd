extends Node

signal building_state_changed(is_building) # Triggers when player starts/stops building preview
signal player_max_health_changed(max_health)
signal player_health_changed(health, shot)
signal xp_changed(amount)
signal level_up(level)
signal cash_changed(cash)
signal stat_update(id)
signal effect_activated(effect)
signal destroy_area(center_pos, size) # size = int

const STARTING_CASH := 100 # level 1 shop cash
const STARTING_HEALTH := 100.0
const STARTING_TOWER_SLOTS := 5
const INITIAL_LEVEL_THRESHOLD := 12.0 # Initial XP needed to level up
const LEVEL_PROGRESSION := [ # LevelDatas
	#"res://Levels/NormalProgression/lvl_test_3.tres",
	#"res://Levels/NormalProgression/lvl_test_2.tres",
	#"res://Levels/lvl_test.tres",
	"res://Levels/NormalProgression/level_1.tres",
	"res://Levels/NormalProgression/level_2.tres",
	"res://Levels/NormalProgression/level_3.tres",
	"res://Levels/NormalProgression/level_4.tres",
	"res://Levels/NormalProgression/level_5.tres",
]
const RUN_BACK_PROGRESSION := [ # LevelSaves
	#"res://Levels/RunBackProgression/lvl_test_runback.tres",
	"res://Levels/RunBackProgression/level_1.tres",
	"res://Levels/RunBackProgression/level_2.tres",
	"res://Levels/RunBackProgression/level_3.tres",
	"res://Levels/RunBackProgression/level_4.tres",
]

const HARD_LEVEL_PROGRESSION = [ # deprecated
	"res://Levels/HardProgression/level_1.tres",
	"res://Levels/HardProgression/level_2.tres",
	"res://Levels/HardProgression/level_3.tres",
]

var hit_sounds := 0 # don't allow too many hit sounds at once (dumb solution)
var owned_towers := []
var owned_items := []
var selected_towers := []
var previous_levels := [] # for run back
var previous_maps := [] # kinda deprecated
var current_hat : HatInfo
var current_level # LevelData or LevelSave (run back)
var map_data : MapData
var rng := RandomNumberGenerator.new()

var game_level : int # game progress
var player_level : int # xp levels
var cash : int
var max_health : float
var health : float
var level_up_threshold : float
var level_multiplier : float # Multiples threshold on level up. Set by LevelData
var xp : float
var upgrade_points : int # determines how many upgrades are available
var max_tower_slots : int
var is_player_dead : bool


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	health = max_health
	rng.randomize()


func change_cash(amount: int) -> void:
	cash += amount
	emit_signal("cash_changed", cash)


func change_max_health(amount: float) -> void:
	max_health += amount
	emit_signal("player_max_health_changed", max_health)


func change_health(amount: float, shot := true) -> void:
	if is_player_dead:
		return
	health -= amount
	if health > max_health:
		health = max_health
	elif health <= 0.0:
		is_player_dead = true
	emit_signal("player_health_changed", health, shot)


func change_xp(amount: float) -> void:
	xp += amount
	if (xp >= level_up_threshold):
		xp -= level_up_threshold
		level_up_threshold *= level_multiplier
		player_level += 1
		print("level " + String(player_level))
		emit_signal("level_up", player_level)
	emit_signal("xp_changed", xp)


func switch_levels():
	var levels := HARD_LEVEL_PROGRESSION if (Modifiers.hard_mode) else LEVEL_PROGRESSION
	game_level += 1
	var run_back := false
	if game_level > LEVEL_PROGRESSION.size():
		run_back = true
		current_level = load(RUN_BACK_PROGRESSION[game_level - 1 - LEVEL_PROGRESSION.size()])
		var map_save = previous_levels[game_level - 1 - LEVEL_PROGRESSION.size()]
		print(map_save.entrance_dir)
		current_level.map_save = map_save
	else:
		current_level = load(levels[game_level - 1])
		level_multiplier = current_level.level_multiplier
		# Set map
		var map_pool : Array = current_level.maps
		var new_map : MapData = map_pool[rng.randi_range(0, map_pool.size() - 1)]
		var i := 0
		while (previous_maps.has(new_map)):
			if i > 6:
				break
			new_map = map_pool[rng.randi_range(0, map_pool.size() - 1)]
			i += 1
		previous_maps.append(new_map)
		map_data = new_map
	current_level.generate_wave_data(rng)
	
	
	TransitionService.fade_out("res://Levels/!Scenes/GameLevel.tscn", run_back)
	Achievements.handle_event(Achievements.LEVEL_START)


func reset_progress():
	rng.randomize()
	owned_towers.clear()
	owned_items.clear()
	selected_towers.clear()
	previous_maps.clear()
	previous_levels.clear()
	
	game_level = 0
	player_level = 1
	cash = STARTING_CASH
	max_health = STARTING_HEALTH
	health = STARTING_HEALTH
	level_up_threshold = INITIAL_LEVEL_THRESHOLD
	xp = 0
	upgrade_points = 0
	if Modifiers.testing:
		cash = 9999
		max_health = 555555
		health = 555555
		upgrade_points = 10
	max_tower_slots = STARTING_TOWER_SLOTS
	is_player_dead = false
	# reset other autoload thingies
	MusicController.progress = 0
	Modifiers.reset()
	Achievements.reset()
	for tower in TowerDict.stats:
		for stat in TowerDict.stats[tower].keys():
			TowerDict.stats[tower][stat] = 0

func add_sound_effect():
	hit_sounds += 1
	var timer := get_tree().create_timer(0.1)
	timer.connect("timeout", self, "_remove_sound_effect")

func _remove_sound_effect():
	hit_sounds -= 1
