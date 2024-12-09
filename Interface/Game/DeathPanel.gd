extends MarginContainer

onready var title := get_node("%Title")
onready var stats1 := get_node("%StatsCol1")
onready var stats2 := get_node("%StatsCol2")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	SignalBus.connect("player_health_changed", self, "_on_player_health_changed")
	hide()


func _on_player_health_changed(health: float, shot: bool):
	if not SignalBus.is_player_dead:
		return
	
	if shot:
		title.text = "You died"
		$DeathTimer.start(1)
	else:
		title.text = "You're fired"
		$DeathTimer.start(1.5)
	stats1.text = ("Drops collected: " + String(Modifiers.drops_collected) + "\n" + 
	"Drops missed: " + String(Modifiers.drops_missed))
	stats2.text = ("Mobs killed: " + String(Modifiers.mobs_killed) + "\n" + 
	"Mobs missed: " + String(Modifiers.mobs_missed))


func _on_PlayAgain_pressed():
	TransitionService.fade_out("res://Interface/Menus/HatSelect/HatSelect.tscn", true)


func _on_MainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Interface/Main Menu/MainMenu.tscn")


func _on_DeathTimer_timeout():
	get_tree().paused = true
	show()
	
	Steam.setStatInt("runs", Steam.getStatInt("runs") + 1)
	if SignalBus.game_level > 1:
		Steam.setStatInt("lvl1_wins", Steam.getStatInt("lvl1_wins") + 1)
	if SignalBus.game_level > 2:
		Steam.setStatInt("lvl2_wins", Steam.getStatInt("lvl2_wins") + 1)
	Steam.storeStats()
