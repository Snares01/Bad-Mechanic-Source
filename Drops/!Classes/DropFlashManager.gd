extends Node2D
# Draws drops that are currently flashing
var drops := []

onready var drop_manager = get_parent()

func _ready():
	material.set_shader_param("flash", 1.0)
	material.set_shader_param("spritesheet_size", Vector2(1, 1))
	material.set_shader_param("line_width", 0)


func draw_drops(drop_list : Array):
	drops.clear()
	drops = drop_list
	update()


func _draw():
	for drop in drops:
		var drop_spr : StreamTexture = drop_manager.DROP_SPRITES[drop.sprite_index]
		draw_texture(drop_spr, drop.position - 
		Vector2(drop_spr.get_width() / 2.0, drop_spr.get_height() / 2.0))
