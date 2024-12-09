extends CenterContainer

onready var name_label := get_node("%Name")
onready var health_bar := get_node("%HealthBar")

var boss_ref : Boss
var active := false
var bar_fill := 0.0


func _ready():
	$VBox.modulate = Color(1, 1, 1, 0)
	pause_mode = Node.PAUSE_MODE_PROCESS


func _process(delta):
	if active and is_instance_valid(boss_ref):
		health_bar.value = boss_ref.health
	elif not active and bar_fill > 0.0:
		bar_fill = min(bar_fill + delta, 1.0)
		health_bar.value = health_bar.max_value * bar_fill
		if bar_fill >= 1.0:
			active = true


func activate(boss : Boss):
	boss_ref = boss
	name_label.text = boss.boss_name
	health_bar.max_value = boss.max_health
	health_bar.value = 0.0
	$Animator.play("intro")

func fill_bar():
	bar_fill = 0.01
