extends Button


var item_info : ConsumableInfo
var preview := false 

onready var progress_bar := $ProgressBar


func _ready():
	progress_bar.max_value = item_info.cooldown_duration
	if not item_info.is_cooldown:
		progress_bar.value = progress_bar.max_value * (1 - (item_info.uses / float(item_info.max_uses)))


func _process(delta):
	if item_info.is_cooldown:
		progress_bar.value -= delta


func on_pressed():
	if item_info.is_cooldown:
		if progress_bar.value <= 0:
			if item_info.is_cooldown:
				progress_bar.value = progress_bar.max_value
			if preview:
				item_info.activate_preview()
			else:
				item_info.activate_effect()
	elif item_info.uses > 0:
		if preview:
			item_info.activate_preview()
		else:
			item_info.activate_effect()
		progress_bar.value = progress_bar.max_value * (1 - (item_info.uses / float(item_info.max_uses)))
		if item_info.uses == 0:
			SignalBus.owned_items.erase(item_info)
			queue_free()


func load_info(info : ConsumableInfo, prev := false):
	item_info = info
	icon = info.img_ui
	preview = prev

