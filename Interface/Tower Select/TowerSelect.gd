extends Control

const CARD_WIDTH := 40

onready var inventory := get_node("%Inventory")
onready var select_panel := get_node("%SelectPanel")

func _ready():
	select_panel.rect_min_size.x = 10 + (CARD_WIDTH * SignalBus.max_tower_slots)
	inventory.connect("inv_drag", self, "_on_drag")
	select_panel.connect("sel_drag", self, "_on_drag")


func _on_drag(dragging: bool):
	if dragging:
		for card in select_panel.get_node("HBox").get_children():
			card.mouse_filter = Button.MOUSE_FILTER_IGNORE
		for card in inventory.get_node("Grid").get_children():
			card.mouse_filter = Button.MOUSE_FILTER_IGNORE
	else:
		for card in select_panel.get_node("HBox").get_children():
			card.mouse_filter = Button.MOUSE_FILTER_STOP
		for card in inventory.get_node("Grid").get_children():
			card.mouse_filter = Button.MOUSE_FILTER_STOP


func _input(event):
	pass


func _on_continue_pressed():
	SignalBus.selected_towers = select_panel.get_towers()
	SignalBus.switch_levels()
