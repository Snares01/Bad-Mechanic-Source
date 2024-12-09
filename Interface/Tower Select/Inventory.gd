extends MarginContainer

signal inv_drag(dragging)

var card: PackedScene = preload("res://Interface/Tower Select/TowerCard.tscn")

onready var select_panel = get_node("%SelectPanel")
onready var grid = $Grid

func _ready():
	for tower in SignalBus.owned_towers:
		var new_card: TextureButton = card.instance()
		new_card.tower_info = tower.duplicate()
		new_card.load_data()
		new_card.connect("drag", self, "_on_drag")
		grid.add_child(new_card)


func _on_drag(dragging: bool):
	emit_signal("inv_drag", dragging)


func can_drop_data(position: Vector2, data) -> bool:
	var can_drop : bool = data is TextureButton
	return can_drop


func drop_data(position: Vector2, data: TextureButton) -> void:
	if (data.in_inventory == true):
		return
	data.in_inventory = true
	
	var copy: TextureButton = card.instance()
	copy.tower_info = data.tower_info
	copy.load_data()
	
	grid.add_child(copy)
	data.queue_free()
