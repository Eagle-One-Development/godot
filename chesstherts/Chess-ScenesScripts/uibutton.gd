extends Button

@onready var skirmishui = $SkirmishUi

func _ready():
	if get_parent() == $Graveyard:
		print(skirmishui)
		print("skirmishuiyay")
