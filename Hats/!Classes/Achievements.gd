extends Node

enum {
	LEVEL_START,
	TIME_SKIPPED,
	SHOP_PURCHASE,
	EGG_ACQUIRED,
	GAME_COMPLETED,
	SHOP_ITEM_SOLD,
}
const STEAM_APP_ID := 2818660 #playtest: 2853850, real game: 2818660, demo: 2973930
const VERSION := 2 # For stat reset
var shop_cash_spent := 0 # for monocle
var shop_sold_value := 0 # cape
var has_item_been_sold := false # jester

func _init() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))


func _ready() -> void:
	_initialize_steam()
	# for demo VVVVV
	#if VERSION != Steam.getStatInt("version"):
	#Steam.resetAllStats(true)
	#	print("STEAM STATS RESET")
	#	Steam.setStatInt("version", VERSION)
	#Steam.storeStats()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(true, STEAM_APP_ID)
	print("Steam initialization: %s" % initialize_response)

# Called by random shit from everywhere, rewards hats when appropriate
func handle_event(event : int) -> void:
	match event:
		LEVEL_START:
			print(SignalBus.game_level)
			if SignalBus.game_level == 1:
				has_item_been_sold = false
			if SignalBus.game_level == 2 and not is_achieved("HT_FOOTBALL_HELMET"):
				_set_achievement("HT_FOOTBALL_HELMET")
			if SignalBus.game_level == 2 and Modifiers.drops_missed == 0 and not is_achieved("HT_TOP_HAT"):
				_set_achievement("HT_TOP_HAT")
			if SignalBus.game_level == 5 and not is_achieved("HT_BUNNY"):
				_set_achievement("HT_BUNNY")
		TIME_SKIPPED:
			if Modifiers.seconds_skipped >= 180 and not is_achieved("HT_CUBAN_LINK"):
				_set_achievement("HT_CUBAN_LINK")
		SHOP_PURCHASE:
			if shop_cash_spent >= 400 and not is_achieved("HT_MONOCLE"):
				_set_achievement("HT_MONOCLE")
		EGG_ACQUIRED:
			if not is_achieved("HT_FRYING_PAN"):
				_set_achievement("HT_FRYING_PAN")
		GAME_COMPLETED:
			if not is_achieved("HT_HARD_HAT"):
				_set_achievement("HT_HARD_HAT")
			if not has_item_been_sold and not is_achieved("HT_CAPE"):
				_set_achievement("HT_CAPE")
		SHOP_ITEM_SOLD:
			has_item_been_sold = true
			if shop_sold_value >= 400 and not is_achieved("HT_JESTER"):
				_set_achievement("HT_JESTER")

# Used by HatSelect as well
func is_achieved(value: String) -> bool:
	var achoo : Dictionary = Steam.getAchievement(value)
	if achoo['ret'] and achoo['achieved']:
		return true
	return false


func _set_achievement(value: String):
	Steam.setAchievement(value)
	Steam.storeStats()


func reset():
	has_item_been_sold = false
	shop_cash_spent = 0
