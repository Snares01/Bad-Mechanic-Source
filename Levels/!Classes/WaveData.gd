extends Resource
class_name WaveData

var mob_list := []

export(Array, Array, Vector3) var timeline
# An array of waves that each contain an array of mob spawns
# x = ID of unit
# y = Amount of units to be spawned
# z = Time (sec) between spawns
