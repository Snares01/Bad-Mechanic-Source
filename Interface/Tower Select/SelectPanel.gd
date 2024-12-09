extends PanelContainer

signal sel_drag(dragging)

var card: PackedScene = preload("res://Interface/Tower Select/TowerCard.tscn")

onready var inventory = get_node("%Inventory")


func can_drop_data(position: Vector2, data) -> bool:
	var can_drop : bool = data is TextureButton
	return can_drop


func get_towers() -> Array:
	var tower_list := []
	for card in $HBox.get_children():
		tower_list.append(card.tower_info)
	return tower_list


func drop_data(position: Vector2, data: TextureButton) -> void:
	if (data.in_inventory == false or $HBox.get_child_count() >= SignalBus.max_tower_slots):
		return
	data.in_inventory = false
	
	var copy: TextureButton = card.instance()
	copy.tower_info = data.tower_info
	copy.in_inventory = false
	copy.connect("drag", self, "_on_drag")
	copy.load_data()
	
	$HBox.add_child(copy)
	#emit_signal("card_selected", data)
	data.queue_free()


func _on_drag(dragging: bool):
	emit_signal("sel_drag", dragging)
