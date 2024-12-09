extends Control


onready var time_text := get_node("%TimeText")
onready var cash_text := get_node("%CashText")
onready var hat_spr := get_node("%HatSprite")

func _ready():
	var seconds := String(round(fmod(Modifiers.run_length, 60.0)))
	var minutes := String(floor(Modifiers.run_length / 60.0))
	if seconds.length() == 1:
		seconds = "0" + seconds
	if minutes.length() == 1:
		minutes = "0" + minutes
	cash_text.text = "With $" + String(SignalBus.cash)
	time_text.text = minutes + ":" + seconds
	
	if SignalBus.current_hat != null:
		hat_spr.texture = SignalBus.current_hat.spr
	else:
		hat_spr.hide()
	
	Achievements.handle_event(Achievements.GAME_COMPLETED)
	Steam.setStatInt("runs", Steam.getStatInt("runs") + 1)
	Steam.setStatInt("lvl1_wins", Steam.getStatInt("lvl1_wins") + 1)
	Steam.setStatInt("lvl2_wins", Steam.getStatInt("lvl2_wins") + 1)
	Steam.setStatInt("lvl3_wins", Steam.getStatInt("lvl3_wins") + 1)
	Steam.storeStats()
	
	# score
	var leftover_cash_bonus: int = SignalBus.cash * 10
	var skip_bonus: int = Modifiers.seconds_skipped * 50
	var towers_placed_bonus: int = Modifiers.towers_placed * 100
	var tower_unlock_bonus: int = Modifiers.towers_unlocked * 200
	var item_unlock_bonus: int = Modifiers.items_unlocked * 200
	var health_bonus: int = round(SignalBus.health * 50)
	var pickup_multiplier: float = min(stepify(float(Modifiers.drops_collected) / max(Modifiers.drops_missed, 1), 0.01), 100.0)
	var score: int = 1000
	
	print("Cash left: " + str(leftover_cash_bonus))
	print("Seconds skipped: " + str(skip_bonus))
	print("Towers placed: " + str(towers_placed_bonus))
	print("Towers unlocked: " + str(tower_unlock_bonus))
	print("Items unlocked: " + str(item_unlock_bonus))
	print("Health left: " + str(health_bonus))
	print("Cash picked up: $" + str(pickup_multiplier))
	print("Cash pickup multiplier: " + str(pickup_multiplier))
	
	score += (leftover_cash_bonus + skip_bonus + towers_placed_bonus + tower_unlock_bonus
	 + item_unlock_bonus + health_bonus) * pickup_multiplier
	print("Score: " + str(score))


func _on_PlayAgain_pressed():
	SignalBus.reset_progress()
	get_tree().change_scene("res://Interface/Main Menu/MainMenu.tscn")
