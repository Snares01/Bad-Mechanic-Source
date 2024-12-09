extends Area2D

const ARROW_TICK_SPEED := 0.66

var active := false

onready var arrow := $Arrow

func _ready():
	monitorable = false
	monitoring = false
	arrow.hide()
	if not is_connected("area_entered", self, "_on_LevelEndTrigger_area_entered"):
		connect("area_entered", self, "_on_LevelEndTrigger_area_entered")


func update_position(entrance_dir : Vector2):
	look_at(entrance_dir)
	match entrance_dir:
		Vector2.RIGHT:
			$InvisibleWall/TopWall.position.y -= 3
			$InvisibleWall/BottomWall.position.y += 2
		Vector2.LEFT:
			$InvisibleWall/BottomWall.position.y += 3
			$InvisibleWall/TopWall.position.y -= 2


func activate():
	monitoring = true
	active = true
	$Timer.start(ARROW_TICK_SPEED)
	

func _on_LevelEndTrigger_area_entered(area):
	if not area.get_parent().has_method("disable"):
		return
	area.get_parent().disable()
	print(str(SignalBus.game_level) + "/" + str(SignalBus.LEVEL_PROGRESSION.size()))
	if SignalBus.game_level == (SignalBus.LEVEL_PROGRESSION.size() * 2) - 1: # final level
		print("final level")
		#TransitionService.fade_out("res://Interface/Menus/WinScreen.tscn")
		TransitionService.fade_out("res://Interface/EndingCutscene/EndingCutscene.tscn")
	elif SignalBus.game_level >= SignalBus.LEVEL_PROGRESSION.size(): # run back
		print("run back")
		SignalBus.switch_levels()
	else: # main run
		print("main level")
		TransitionService.fade_out("res://Interface/Shop/Shop.tscn")


func _on_Timer_timeout():
	if arrow.visible:
		arrow.hide()
	else:
		arrow.show()
