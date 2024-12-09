extends Node

# Stats
var run_length : float
var drops_collected : int
var drops_missed : int
var mobs_killed : int
var mobs_missed : int
var seconds_skipped : int
var towers_placed : int
var towers_unlocked : int
var items_unlocked : int
# Modifiers
var coins_activated : bool
var poison_multiplier : float
var freeze_multiplier : float
var stun_multiplier : float
var path_complete_damage_multiplier : float
var collect_radius_multiplier : float
var build_radius_multiplier : float
var golden_skip : float
# Settings
var hard_mode := false # deprecated
var skip_intro := false
# Hints
var hints := true
var hint_buy_menu := true
var hint_sell_menu := true
var hint_modifier_preview := true
var hint_tower_level := true
# Testing
var testing := false
var damage_dealt : float

onready var dps_timer := Timer.new()

func _ready():
	add_child(dps_timer)
	if testing:
		damage_dealt = 0.0
		dps_timer.start(10.0)
		dps_timer.connect("timeout", self, "track_dps")

func _process(delta):
	run_length += delta
	if Input.is_action_just_pressed("fast_forward") and testing:
		if Engine.time_scale > 1.0:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 3

func reset():
	# Stats
	run_length = 0.0
	drops_collected = 0
	drops_missed = 0
	mobs_killed = 0
	mobs_missed = 0
	seconds_skipped = 0
	towers_placed = 0
	towers_unlocked = 0
	items_unlocked = 0
	# Modifiers
	coins_activated = false
	poison_multiplier = 0.8 # damage multiplier per poison tick
	freeze_multiplier = 1.0
	stun_multiplier = 1.0
	path_complete_damage_multiplier = 1.0
	collect_radius_multiplier = 1.0
	build_radius_multiplier = 1.0
	golden_skip = false
	# Testing
	damage_dealt = 0.0 # for dps
	

func track_dps():
	print("DPS: " + String(damage_dealt / 10.0))
	damage_dealt = 0.0
