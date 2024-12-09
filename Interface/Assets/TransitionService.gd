extends CanvasLayer

var next_scene : String
var next_scene_packed : PackedScene
var is_packed_scene := false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func fade_out(next : String, run_back := false):
	next_scene = next
	is_packed_scene = false
	$Animator.play("fade_out")
	if not run_back:
		MusicController.fade_out()

func fade_out_to(next : PackedScene):
	next_scene_packed = next
	is_packed_scene = true
	$Animator.play("fade_out")
	MusicController.fade_out()


func fade_in():
	$Animator.play("fade_in")


func _on_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().paused = false
		if is_packed_scene:
			get_tree().change_scene_to(next_scene_packed)
		else:
			get_tree().change_scene(next_scene)
		fade_in()
	
