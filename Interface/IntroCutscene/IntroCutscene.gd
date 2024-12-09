extends Node2D

onready var animator : AnimationPlayer = $Animator

var skipped := false

func _ready():
	$UILayer.show()
	get_node("%InitialDialogue").connect("finished", self, "_show_office")
	#get_node("%BossDialogue").connect("finished", self, "show_leaderboard")
	var timer := get_tree().create_timer(0.66)
	timer.connect("timeout", self, "_start_dialogue")

func _start_dialogue():
	get_node("%InitialDialogue").start()

func _show_office():
	animator.play("show_office", -1, 0.8)
	$UILayer/SkipContainer.hide()

func _on_boss_message(msg_num: int):
	if msg_num == 1:
		_show_leaderboard()
	elif msg_num == 2:
		get_node("%Leaderboard").hide()
		var timer := get_tree().create_timer(0.5)
		timer.connect("timeout", self, "_joe_dialogue")

func _show_leaderboard():
	get_node("%Leaderboard").show()
	animator.play("leaderboard")

func _joe_dialogue():
	get_node("%SchmuckDialogue").start()
	get_node("%SchmuckDialogue").connect("finished", self, "_boss_dialogue")

func _boss_dialogue():
	get_node("%Boss2").start()
	get_node("%Boss2").connect("finished", self, "_end_dialogue")

func _end_dialogue():
	TransitionService.fade_out("res://Interface/Shop/Shop.tscn")

func _on_animation_finished(anim_name : String):
	match anim_name:
		"show_office":
			get_node("%BossDialogue").start()
			get_node("%BossDialogue").connect("new_message", self, "_on_boss_message")
		"leaderboard":
			return
			#get_node("%BossDialogue").next_message()
			#get_node("%Leaderboard").hide()
			#var timer := get_tree().create_timer(0.5)
			#timer.connect("timeout", self, "_joe_dialogue")


func _on_SkipIntro_button_down():
	if not skipped:
		skipped = true
		Modifiers.skip_intro = true
		var config := ConfigFileHandler.config
		config.set_value("gameplay", "skip-intro", true)
		config.save(ConfigFileHandler.SETTINGS_FILE_PATH)
		TransitionService.fade_out("res://Interface/Shop/Shop.tscn")
