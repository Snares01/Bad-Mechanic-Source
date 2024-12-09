extends MarginContainer

const CONSUMABLE = preload("res://Interface/Game/ConsumableButton.tscn")

onready var hbox = $VBox
export var spawn_cards := true


func _ready():
	if spawn_cards:
		for item in SignalBus.owned_items:
			if not item is ConsumableInfo:
				continue
			var instance = CONSUMABLE.instance()
			instance.load_info(item)
			hbox.add_child(instance)


func _input(event):
	if Input.is_action_just_pressed("use_item_1"):
		use_item(1)
	elif Input.is_action_just_pressed("use_item_2"):
		use_item(2)
	elif Input.is_action_just_pressed("use_item_3"):
		use_item(3)


func use_item(num : int):
	var cards = hbox.get_children()
	if cards.size() >= num:
		cards[num - 1].on_pressed()


func create_card(card_info : ConsumableInfo, preview := false):
	var instance = CONSUMABLE.instance()
	instance.load_info(card_info, preview)
	hbox.add_child(instance)

func clear():
	for card in hbox.get_children():
		hbox.remove_child(card)
