extends Hurtbox


func is_in_group(group : String):
	if group == "Player":
		return true
	return false
