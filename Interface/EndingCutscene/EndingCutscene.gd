extends Control

const SCORE_SOUNDS := [
	preload("res://Interface/EndingCutscene/score_1.wav"),
	preload("res://Interface/EndingCutscene/score_2.wav"),
	preload("res://Interface/EndingCutscene/score_3.wav"),
	preload("res://Interface/EndingCutscene/score_4.wav"),
	preload("res://Interface/EndingCutscene/score_5.wav"),
]

var pickup_multiplier: float
var score: int = 1000
var bonus_labels := [
	"Cash Left\n",
	"Health Left\n",
	"Seconds Skipped\n",
	"Towers Placed\n",
	"Towers Unlocked\n",
	"Items Unlocked\n"
]
var bonus_points := []
var bonus_stats := []

onready var bonus_label: Label = get_node("%BonusLabels")
onready var points: Label = get_node("%Points")
onready var score_label: Label = get_node("%Score")
onready var job_label: Label = get_node("%JobLabel")
onready var time_label: Label = get_node("%TimeText")
onready var hat_spr: Sprite = get_node("%HatSprite")
onready var score_sfx: AudioStreamPlayer = get_node("Score")

func _ready():
	bonus_label.text = ""
	points.text = ""
	$Black.show()
	$Black2.show()
	_calculate_score()
	get_node("%Dialogue").connect("finished", self, "_show_score")
	# timer
	var seconds := String(round(fmod(Modifiers.run_length, 60.0)))
	var minutes := String(floor(Modifiers.run_length / 60.0))
	if seconds.length() == 1:
		seconds = "0" + seconds
	if minutes.length() == 1:
		minutes = "0" + minutes
	time_label.text = minutes + ":" + seconds
	# hat
	if SignalBus.current_hat != null:
		hat_spr.texture = SignalBus.current_hat.end_screen_icon
	else:
		hat_spr.hide()
	# stats / achievements
	Achievements.handle_event(Achievements.GAME_COMPLETED)
	Steam.setStatInt("runs", Steam.getStatInt("runs") + 1)
	Steam.setStatInt("lvl1_wins", Steam.getStatInt("lvl1_wins") + 1)
	Steam.setStatInt("lvl2_wins", Steam.getStatInt("lvl2_wins") + 1)
	Steam.setStatInt("lvl3_wins", Steam.getStatInt("lvl3_wins") + 1)
	Steam.storeStats()
	yield(get_tree().create_timer(1.0), "timeout")
	get_node("%Dialogue").start()

func _calculate_score():
	var leftover_cash_bonus = SignalBus.cash * 10
	var skip_bonus = Modifiers.seconds_skipped * 30
	var towers_placed_bonus = Modifiers.towers_placed * 100
	var tower_unlock_bonus = Modifiers.towers_unlocked * 200
	var item_unlock_bonus = Modifiers.items_unlocked * 200
	var health_bonus = round(SignalBus.health * 50)
	pickup_multiplier = min(stepify(float(Modifiers.drops_collected) / max(Modifiers.drops_missed, 1), 0.01), 100.0)
	bonus_points = [leftover_cash_bonus, health_bonus, skip_bonus, towers_placed_bonus, tower_unlock_bonus, item_unlock_bonus, pickup_multiplier]
	bonus_stats = [SignalBus.cash, round(SignalBus.health), Modifiers.seconds_skipped, Modifiers.towers_placed, Modifiers.towers_unlocked, Modifiers.items_unlocked]


func _show_score():
	$Black.hide()
	yield(get_tree().create_timer(1.25), "timeout")
	for i in bonus_labels.size():
		bonus_label.text += bonus_labels[i]
		points.text += str(bonus_stats[i]) + "\n"
		score += bonus_points[i]
		score_label.text = str(score)
		# score sound
		if i < 2:
			score_sfx.stream = SCORE_SOUNDS[0]
		elif i < 4:
			score_sfx.stream = SCORE_SOUNDS[1]
		elif i < 5:
			score_sfx.stream = SCORE_SOUNDS[2]
		else:
			score_sfx.stream = SCORE_SOUNDS[3]
		score_sfx.play()
		yield(get_tree().create_timer(1.5), "timeout")
	
	bonus_label.text += "Cash Miss Rate"
	points.text += "%.2fx" % pickup_multiplier
	score *= pickup_multiplier
	score_label.text = str(score)
	score_sfx.stream = SCORE_SOUNDS[4]
	score_sfx.play()
	yield(get_tree().create_timer(1.5), "timeout")
	$Music.play()
	
	if score < 40_000:
		job_label.text = "Assistant to the Regional Manager"
	elif score < 70_000:
		job_label.text = "Senior Light Bulb Analyst"
	elif score < 90_000:
		job_label.text = "Trojan Horse Inspector"
	elif score < 120_000:
		job_label.text = "Portal Supervisor"
	elif score < 150_000:
		job_label.text = "Head of Pest Control"
	else:
		job_label.text = "Chief Executive Gamer"
	
	var timer := get_tree().create_timer(2.5)
	timer.connect("timeout", self, "_show_menu")

func _show_menu():
	$Black2.hide()


func _on_Hooray_pressed():
	get_node("ButtonContainer/Hooray").disabled = true
	TransitionService.fade_out("res://Interface/Main Menu/MainMenu.tscn")
