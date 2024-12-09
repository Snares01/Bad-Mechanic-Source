extends TextureButton

signal drag(dragging)

var in_inventory := true
var tower_info : TowerInfo

func get_drag_data(_position: Vector2):
	toggle_mode = true
	pressed = true
	emit_signal("drag", true)
	set_drag_preview(_get_preview_control())
	return self


func _get_preview_control() -> TextureRect:
	var preview = TextureRect.new()
	preview.texture = texture_normal
	preview.modulate.a = 0.5
	preview.connect("tree_exiting", self, "_on_preview_exited")
	return preview


func _on_preview_exited():
	emit_signal("drag", false)
	pressed = false
	toggle_mode = false


func load_data():
	texture_normal = tower_info.img_normal
