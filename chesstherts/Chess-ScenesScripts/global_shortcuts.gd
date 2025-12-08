extends Node

func _unhandled_input(event):
	if event.is_action_pressed("new_skirmish"):
		SkirmishManager.create_skirmish()
		print("global shortcut NEW SKIRMISH")
