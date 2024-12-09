extends VBoxContainer

var rng = RandomNumberGenerator.new()
var build_ui = null
var tower : TowerInfo
var stats : Dictionary
var mouse_hovering := false
var player_ref
var blink_step := 0 # For upgrade blinking on level up

var hard_mode := false # enabled by hard hat

export var blink_texture : StreamTexture
export var nonblink_texture : StreamTexture
onready var card := $Card
onready var level_txt := $Level

func _ready():
	rng.randomize()
	SignalBus.connect("cash_changed", self, "_on_cash_change")
	SignalBus.connect("building_state_changed", self, "_on_building_preview")
	SignalBus.connect("level_up", self, "_on_level_up")
	card.material.set_shader_param("spritesheet_size", Vector2(1, 1))
	if SignalBus.upgrade_points > 0:
		if tower.level < tower.max_level:
			toggle_upgrade(true)
		else:
			toggle_upgrade(false)
	else:
		toggle_upgrade(false, true)
	if SignalBus.current_hat != null:
		SignalBus.current_hat.tower_card_effect(self)
	
	if SignalBus.cash < tower.cost:
		card.disabled = true
		card.material.set_shader_param("flash_col", Color(0, 0, 0, 1))
		card.material.set_shader_param("flash", 0.3)

func _on_level_up(_level):
	blink_step = 0
	blinky()

func blinky(): # Flash upgrade buttons on level up
	blink_step += 1
	if blink_step % 2 == 1:
		$Upgrade.texture_normal = blink_texture
	else:
		$Upgrade.texture_normal = nonblink_texture
	
	if blink_step < 8:
		var timer := get_tree().create_timer(0.12)
		timer.connect("timeout", self, "blinky")

func _on_cash_change(cash):
	if cash < tower.cost:
		card.disabled = true
		card.material.set_shader_param("flash_col", Color(0, 0, 0, 1))
		card.material.set_shader_param("flash", 0.3)
	else:
		card.disabled = false
		card.material.set_shader_param("flash_col", Color(1, 1, 1, 1))
		card.material.set_shader_param("flash", 0.0)


func _on_building_preview(building):
	card.material.set_shader_param("flash_col", Color(1, 1, 1, 1))
	card.material.set_shader_param("flash", 0.0)


func _on_card_pressed():
	level_txt.text = ""
	if SignalBus.cash < tower.cost:
		return
	var instance : TowerPreview = tower.preview_instance.instance()
	instance.cost = tower.cost
	instance.player_ref = player_ref
	SignalBus.emit_signal("building_state_changed", true)
	get_node("/root/GameController/LevelGenerator/BottomMap").add_child(instance)


func _on_upgrade_pressed():
	SignalBus.upgrade_points -= 1
	tower.level += 1
	_update_level_text()
	# Update stats & send signal
	var keys := stats.keys()
	var values := stats.values()
	for i in range(0, keys.size()):
		TowerDict.stats[tower.id][keys[i]] += values[i]
	SignalBus.emit_signal("stat_update", tower.id)
	
	if SignalBus.upgrade_points < 1:
		build_ui.toggle_upgrades(false, true)
	else:
		build_ui.toggle_upgrades(true)
		if tower.level >= tower.max_level:
			toggle_upgrade(false)
			build_ui.unprint_upgrade()
		elif mouse_hovering:
			build_ui.print_upgrade(stats)


func toggle_upgrade(activate := true, hide := false):
	if activate:
		if tower.level < tower.max_level:
			$Upgrade.show()
			stats = _select_upgrade(tower.id)
		else:
			$Upgrade.disabled = true
			stats = {}
			$Upgrade.show()
	else:
		if hide:
			$Upgrade.hide()
		else:
			$Upgrade.disabled = true
			stats = {}
			$Upgrade.show()


func load_data():
	$Card.texture_normal = tower.img_normal


func is_upgrade_active() -> bool:
	if $Upgrade.visible == true:
		return true
	return false

# Returns a dictionary of randomly chosen stat upgrades
func _select_upgrade(id: int) -> Dictionary:
	# choose upgrade format
	var stats : Array = TowerDict.stats[id].keys()
	var roll = randf()
	var firstStat : String = stats[rng.randi_range(0, stats.size() - 1)]
	var secondStat : String
	var thirdStat : String
	
	var format = 0 # default format (only format for towers with 1 stat)
	if stats.size() == 1:
		if roll < 0.95:
			format = 0
			if hard_mode and roll < 0.25:
				format = 3
		else:
			format = 3
	elif stats.size() == 2:
		# choose stats
		secondStat = stats[rng.randi_range(0, stats.size() - 1)]
		while (secondStat == firstStat):
			secondStat = stats[rng.randi_range(0, stats.size() - 1)]
		# choose format
		if roll < 0.5:
			format = 0
			if hard_mode and roll < 0.25:
				format = 3
		elif roll < 0.95:
			format = 1
		elif roll < 0.98:
			format = 4
		else:
			format = 3
	elif stats.size() > 2:
		# choose stats
		secondStat = stats[rng.randi_range(0, stats.size() - 1)]
		while (secondStat == firstStat):
			secondStat = stats[rng.randi_range(0, stats.size() - 1)]
		thirdStat = stats[rng.randi_range(0, stats.size() - 1)]
		while (thirdStat == secondStat or thirdStat == firstStat):
			thirdStat = stats[rng.randi_range(0, stats.size() - 1)]
		if roll < 0.4:
			format = 0
			if hard_mode and roll < 0.125:
				format = 3
		elif roll < 0.7:
			format = 1
			if hard_mode and roll < 0.525:
				format = 5
		elif roll < 0.95:
			format = 2
		elif roll < 0.97:
			format = 3
		elif roll < 0.99:
			format = 4
		else:
			format = 5
	# Create dictionary
	var upgrade_dict = {}
	match format:
		0: # +stat
			upgrade_dict[firstStat] = 1
		1: # ++stat, -stat
			upgrade_dict[firstStat] = 2
			upgrade_dict[secondStat] = -1
		2: # +stat, +stat, -stat
			upgrade_dict[firstStat] = 1
			upgrade_dict[secondStat] = 1
			upgrade_dict[thirdStat] = -1
		3: # ++stat
			upgrade_dict[firstStat] = 2
		4: # +stat, +stat
			upgrade_dict[firstStat] = 1
			upgrade_dict[secondStat] = 1
		5: # ++stat, +stat, -stat
			upgrade_dict[firstStat] = 2
			upgrade_dict[secondStat] = 1
			upgrade_dict[thirdStat] = -1
	
	return upgrade_dict

# Upgrade preview text
func _on_mouse_entered(): # UPGRADE BUTTON NOT CARD
	build_ui.print_upgrade(stats)
	mouse_hovering = true

func _on_mouse_exited(): # UPGRADE BUTTON NOT CARD
	build_ui.unprint_upgrade()
	mouse_hovering = false

# Pressed effect
func _on_Card_button_down():
	card.material.set_shader_param("line_color", Color(1, 1, 1, 1))

func _on_Card_button_up():
	card.material.set_shader_param("line_color", Color(1, 1, 1, 0))

# Hover effect
func _on_Card_mouse_entered():
	build_ui.update_level_text(true)
	_update_level_text()
	if not card.disabled:
		card.material.set_shader_param("flash", 0.25)
	if card.pressed:
		card.material.set_shader_param("line_color", Color(1, 1, 1, 1))

func _on_Card_mouse_exited():
	build_ui.update_level_text(false)
	if not card.disabled:
		card.material.set_shader_param("flash", 0.0)
	card.material.set_shader_param("line_color", Color(1, 1, 1, 0))


func _update_level_text():
	if tower.level >= tower.max_level:
		level_txt.text = "MAX"
	else:
		level_txt.text = String(tower.level) + "/" + String(tower.max_level)
