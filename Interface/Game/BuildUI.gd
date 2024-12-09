extends MarginContainer

onready var towers : HBoxContainer = get_node("%Towers")
onready var upgrade_text : Label = get_node("%UpgradeText")
onready var instructions : HBoxContainer = get_node("%Instructions")
onready var points : Label = get_node("%Points")

const CARD = preload("res://Interface/Game/TowerCard.tscn")
var rng = RandomNumberGenerator.new()
var player_ref

func _ready():
	instructions.hide()
	rng.randomize()
	SignalBus.connect("building_state_changed", self, "_on_building_state_change")
	SignalBus.connect("level_up", self, "_on_level_up")
	SignalBus.connect("stat_update", self, "_on_stat_update")
	if (SignalBus.upgrade_points > 0):
		#toggle_upgrades(true)
		points.text = "Points: " + str(SignalBus.upgrade_points)
	
	for tower in SignalBus.selected_towers:
		var instance = CARD.instance()
		instance.tower = tower
		instance.load_data()
		instance.build_ui = self
		instance.player_ref = player_ref
		towers.add_child(instance)

# Event signals
func _on_building_state_change(building : bool):
	if building:
		towers.hide()
		upgrade_text.hide()
		instructions.show()
	else:
		towers.show()
		upgrade_text.show()
		instructions.hide()

func highlight_cards(highlight : bool):
	for tower in towers.get_children():
		if highlight:
			tower.get_node("Upgrade").modulate = Color(2.3, 2.3, 2.3)
		else:
			tower.get_node("Upgrade").modulate = Color(1, 1, 1)

func _on_level_up(level: int):
	SignalBus.upgrade_points += 1
	if (not towers.get_children().empty()) and towers.get_children()[0].is_upgrade_active() == false:
		toggle_upgrades(true)
	#print("You have " + str(SignalBus.upgrade_points) + " upgrades to spend")
	points.text = "Points: " + str(SignalBus.upgrade_points)

func _on_stat_update(_id):
	if points.text != "":
		points.text = "Points: " + str(SignalBus.upgrade_points)

func toggle_upgrades(activate := true, hide := false):
	for tower in towers.get_children():
		tower.toggle_upgrade(activate, hide)
	if not activate:
		points.text = ""
		upgrade_text.text = ""

# Creates text showing upgrade
func print_upgrade(upgrades : Dictionary) -> void:
	var cool_string : String
	var keys := upgrades.keys()
	var values := upgrades.values()
	for i in range(0, upgrades.size()):
		if values[i] == -1:
			cool_string += "- "
		elif values[i] == 1:
			cool_string += "+ "
		else:
			cool_string += "++"
		cool_string += keys[i]
		if i < upgrades.size() - 1:
			cool_string += "\n"
	upgrade_text.text = cool_string

func unprint_upgrade() -> void:
	upgrade_text.text = ""

func update_level_text(show : bool) -> void:
	for tower in towers.get_children():
		tower.level_txt.text = ""
		tower.level_txt.visible = show
