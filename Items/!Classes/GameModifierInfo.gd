extends ItemInfo
class_name GameModifierInfo

export(StreamTexture) var preview_sprite
export(PackedScene) var effect
export var repeating := false # Allows item to be purchased multiple times in a run

func activate_effect():
	SignalBus.emit_signal("effect_activated", effect.instance())
