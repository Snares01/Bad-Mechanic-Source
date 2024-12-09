extends VBoxContainer

signal finished()
signal new_message(msg_num)

export(Array, String, MULTILINE) var messages := []
export var speaker := ""
export(Array, AudioStreamRandomPitch) var talk_sounds := []
export var read_speed := 0.2 # time between characters
export var auto_start := true
export var pause := false
export var allow_type_skip := true
export var allow_message_skip := true

var current_message := 0
var current_char := 0
var ready_to_continue := false

onready var text : Label = $DialogueBox/Text
onready var title : Label = $Title
onready var timer : Timer = $DialogueBox/TypingTimer
onready var audio : AudioStreamPlayer = $Audio

func _ready():
	if pause:
		pause_mode = Node.PAUSE_MODE_PROCESS
	timer.wait_time = read_speed
	if auto_start:
		start()
	else:
		hide()
	title.text = speaker


func start():
	if pause:
		get_tree().paused = true
	timer.start()
	show()


func _on_TypingTimer_timeout():
	if current_char < len(messages[current_message]):
		var next_char : String = messages[current_message][current_char]
		text.text += next_char
		current_char += 1
		audio.stream = talk_sounds[SignalBus.rng.randi_range(0, talk_sounds.size() - 1)]
		if next_char != " ":
			audio.play()
	else:
		ready_to_continue = true
		timer.stop()

#func _unhandled_key_input(event: InputEventKey):
#	if not event.pressed or not visible or event.echo:
#			return
#	_on_input()

func _process(delta):
	if Input.is_action_just_pressed("ui_select") and visible:
		_on_input()

func _on_input():
	if current_message == 0 and current_char < 2:
		return # stops dialogue from skipping twice (shit solution)
	if ready_to_continue and allow_message_skip:
		next_message()
	elif allow_type_skip:
		current_char = len(messages[current_message])
		text.text = messages[current_message]
		ready_to_continue = true
		timer.stop()

# Called externally if allow_message_skip is false
func next_message():
	current_message += 1
	emit_signal("new_message", current_message)
	if current_message < messages.size():
		current_char = 0
		ready_to_continue = false
		text.text = ""
		timer.start()
	else:
		close_box()
	

func close_box():
	emit_signal("finished")
	if pause:
		get_tree().paused = false
	queue_free()
