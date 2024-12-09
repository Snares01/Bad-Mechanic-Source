extends MarginContainer

const PAY_SPEED := 0.1


onready var label : Label = get_node("%Label")
onready var skip : Button = get_node("%Skip")
onready var cash_counter : Label = get_node("%CashCounter")
onready var timer = $Timer

const wave_bonus := 0.5

var is_counting := false
var is_paying := false
var cash_to_pay := 0
var cash_paid := 0
var pay_timer := PAY_SPEED
var current_wave := 0
var max_wave := 1
var skip_reward := 1 # Reward per second, multiplied by level

func _ready():
	skip.text = "Start"
	get_parent().connect("intermission", self, "_on_intermission")
	max_wave = SignalBus.current_level.wave_data.timeline.size()
	$ProgressLabel.text = String(current_wave) + "/" + String(max_wave)


func _process(delta):
	if is_counting and is_paying:
		pay_timer -= delta
		if pay_timer < 0.0:
			pay_timer = PAY_SPEED
			var skip_reward_bonus := 0
			if Modifiers.golden_skip:
				skip_reward_bonus += 2
			SignalBus.change_cash((SignalBus.game_level * skip_reward) + skip_reward_bonus)
			cash_paid += (SignalBus.game_level * skip_reward) + skip_reward_bonus
			cash_to_pay -= 1
			label.text = str(cash_to_pay)
			cash_counter.text = "+" + str(cash_paid)
			if cash_to_pay <= 0:
				is_paying = false
				if timer.time_left > 0:
					timer.stop()
					get_parent().emit_signal("intermission_skipped")
				_on_Timer_timeout()
	elif is_counting:
		label.text = str(ceil(timer.time_left))


func _on_intermission(length := 10.0, wave := 1):
	$Animator.play("RESET")
	timer.start(length)
	cash_counter.text = ""
	current_wave = wave
	is_counting = true
	if current_wave > 1:
		skip.text = "Skip"
	skip.show()

# End of intermission
func _on_Timer_timeout():
	if is_paying:
		return
	$Animator.play("Fade")
	skip.hide()
	is_counting = false
	if current_wave == -1:
		label.text = "Final Wave"
		$ProgressLabel.text = String(max_wave) + "/" + String(max_wave)
	else:
		label.text = "Wave " + str(current_wave)
		$ProgressLabel.text = String(current_wave) + "/" + String(max_wave)


func _on_Skip_pressed():
	if (not is_counting) or is_paying:
		return
	skip.hide()
	
	if current_wave == 1:
		timer.stop()
		_on_Timer_timeout()
		get_parent().emit_signal("intermission_skipped")
		if Modifiers.golden_skip:
			skip.theme = load("res://Interface/Game/Assets/golden_button.tres")
	else:
		cash_to_pay = int(timer.get_time_left()) + 1
		cash_paid = 0
		Modifiers.seconds_skipped += cash_to_pay
		is_paying = true
		
		Achievements.handle_event(Achievements.TIME_SKIPPED)
		
