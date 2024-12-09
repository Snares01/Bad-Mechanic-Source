extends ItemInfo
class_name ConsumableInfo

export var is_cooldown := true
export var cooldown_duration := 10.0
export var max_uses := -1 # Number of uses before deletion (-1 to disable)
export(StreamTexture) var img_ui
export(PackedScene) var consume_effect
export(PackedScene) var preview_effect # Alternative version for use in shop preview

var uses := -1 # set to max_uses on creation

func activate_effect():
	uses -= 1
	SignalBus.emit_signal("effect_activated", consume_effect.instance())


func activate_preview():
	SignalBus.emit_signal("effect_activated", preview_effect.instance())
