extends Window

var skirmish_id: int = -1
@onready var skirmish := $Skirmish

func _ready():
	# forward ID into Skirmish
	skirmish.skirmish_id = skirmish_id

func _on_close_requested():
	SkirmishManager.remove_skirmish(skirmish_id)
	queue_free()
