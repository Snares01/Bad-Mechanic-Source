extends MarginContainer

const HP_DECREASE_SPEED := 13.0
const HP_INCREASE_SPEED := 22.5
const COLOR_HEALTH_INCREASE := Color(0.6, 1.0, 0.66, 1.0)
const COLOR_HEALTH_DECREASE := Color(1, 1, 1, 1)
const COLOR_INCREASE := Color("00c135")
const COLOR_DECREASE := Color("c10000")
const BASE_PITCH := 0.5
const MAX_PITCH := 1.1
const PITCH_CHANGE := 0.025 # How much the pitch changes per dollar
const PITCH_DECAY := 0.33

var tick_reserve := 0
var pitch := BASE_PITCH
var prev_health := 0.0
var prev_cash := 0

onready var health_bar := get_node("%HealthBar")
onready var flash_bar := get_node("%FlashBar")
onready var xp_bar := get_node("%ExpBar")
onready var cash_label := get_node("%Cash")
onready var cash_sfx := get_node("SmallCashSFX")
onready var increase_effect := get_node("%IncreaseEffect")
onready var current_health_label := get_node("%CurrentHealth")

func _ready():
	SignalBus.connect("player_health_changed", self, "_on_player_health_changed")
	SignalBus.connect("player_max_health_changed", self, "_on_player_max_health_changed")
	SignalBus.connect("cash_changed", self, "_on_cash_changed")
	SignalBus.connect("xp_changed", self, "_on_xp_changed")
	SignalBus.connect("level_up", self, "_on_level_up")
	xp_bar.max_value = SignalBus.level_up_threshold
	cash_label.text = "$" + str(SignalBus.cash)
	prev_cash = SignalBus.cash
	prev_health = SignalBus.health
	current_health_label.text = str(round(SignalBus.health))
	health_bar.max_value = SignalBus.max_health
	flash_bar.max_value = SignalBus.max_health
	flash_bar.value = SignalBus.health
	health_bar.value = SignalBus.health
	
	increase_effect.modulate.a = 0.0


func _process(delta):
	pitch = max(BASE_PITCH, pitch - (delta * PITCH_DECAY))
	if tick_reserve != 0 and cash_sfx.playing == false:
		cash_sfx.play()
		tick_reserve -= 1
	if flash_bar.value > prev_health:
		flash_bar.value = max(flash_bar.value - (delta * HP_DECREASE_SPEED * min(SignalBus.max_health / 100, 2)), prev_health)
	if health_bar.value < prev_health:
		health_bar.value = min(health_bar.value + (delta * HP_INCREASE_SPEED * min(SignalBus.max_health / 100, 2)), prev_health)
		#if health_bar.value == prev_health or prev_health >= health_bar.max_value:
		#	flash_bar.modulate = COLOR_HEALTH_DECREASE
	else:
		flash_bar.modulate = COLOR_HEALTH_DECREASE

func _on_player_max_health_changed(max_health : float):
	health_bar.max_value = max_health
	flash_bar.max_value = max_health

func _on_player_health_changed(health, shot):
	if health < prev_health:
		health_bar.value = health
		flash_bar.modulate = COLOR_HEALTH_DECREASE
	else:
		flash_bar.value = health
		flash_bar.modulate = COLOR_HEALTH_INCREASE
	prev_health = health
	current_health_label.text = str(max(round(health), 0))

func _on_xp_changed(xp):
	xp_bar.value = xp

func _on_level_up(_level):
	xp_bar.max_value = SignalBus.level_up_threshold
	$LevelUpSFX.play()

func _on_cash_changed(cash : int):
	cash_label.text = "$" + str(cash)
	
	var cash_change := cash - prev_cash
	if cash_change == 0:
		return
	elif cash_change < 0: # Decrease anim
		increase_effect.text = str(cash_change)
		increase_effect.add_color_override("font_color", COLOR_DECREASE)
		$Animator.stop()
		$Animator.play("Increase")
		increase_effect.modulate.a = 1.0
	elif cash_change > 0 and cash_change < 10: # Tick noise
		pitch += cash_change * PITCH_CHANGE
		cash_sfx.pitch_scale = pitch
		if cash_sfx.playing == false:
			cash_sfx.play()
		else:
			tick_reserve += 1
	else: # Increase anim
		increase_effect.text = "+" + str(cash_change)
		increase_effect.add_color_override("font_color", COLOR_INCREASE)
		$Animator.stop()
		$Animator.play("Increase")
		increase_effect.modulate.a = 1.0
	
	prev_cash = cash


