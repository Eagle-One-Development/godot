# SkirmishManager.gd
extends Node

var next_id := 1
var skirmishes := {}   # id → window instance

@export var skirmish_window_scene: PackedScene   # assign in inspector

func create_skirmish():
	var win = skirmish_window_scene.instantiate()
	var id = next_id
	next_id += 1
	
	win.skirmish_id = id
	skirmishes[id] = win
	
	get_tree().root.add_child(win)
	win.title = "Skirmish " + str(id)
	
	return win

func remove_skirmish(id: int):
	if id in skirmishes:
		skirmishes[id].queue_free()
		skirmishes.erase(id)
