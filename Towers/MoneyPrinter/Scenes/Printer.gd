extends Tower

const BASE_RANGE := 25.0
const BASE_MONEY_OUTPUT := 21
const DROP_RANGE := 16
const TIME_BETWEEN_SPAWNS := 0.18

var money_output := BASE_MONEY_OUTPUT
var cash_left := 0


func update_stats():
	money_output = round(BASE_MONEY_OUTPUT + (TowerDict.stats[id]["Money"] * 1.25))
	sight_range = BASE_RANGE

func _ready():
	yield(get_tree(), "idle_frame")
	if not preview:
		var game_controller := get_parent().get_parent()
		game_controller.gui.connect("intermission", self, "_on_intermission")
		game_controller.connect("level_end", self, "print_money")

func _on_intermission(_arg, arg2):
	print_money()

func print_money():
	cash_left = money_output
	spew_forth()

func spew_forth():
	cash_left -= 1
	var drop_controller := get_parent()
	# TODO: make cash fly downwards only
	drop_controller.create_cash(global_position, 1, DROP_RANGE, Vector2.DOWN)
	
	if cash_left > 0:
		var timer := get_tree().create_timer(TIME_BETWEEN_SPAWNS)
		timer.connect("timeout", self, "spew_forth")
