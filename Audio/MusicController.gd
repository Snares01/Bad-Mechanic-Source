extends Node


onready var track1 := $Track1
var progress := 0.0

# To do: handle transitions between two songs

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func fade_out():
	if track1.playing == false:
		return
	progress = $Track1.get_playback_position()
	$Transition.play("FADE_OUT")


func fade_in(audio : AudioStream):
	track1.stream = audio
	track1.play()
	$Transition.play("FADE_IN")

func jump_to(time : float):
	track1.seek(time)
