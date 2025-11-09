# SKIRMISHUI
# need to make buttons appear
# the layout of SKIRMISHUI will be fixed, non dynamic


extends Control

var skirmish: Node = null
var turns_type: String = "skirmish"
@export var ui_x: int = 264
#@export var ui_y: int = 200


@onready var Button1 = $SkirmishUi/Panel/VBoxContainer/Button1

func init(skirmish_ref: Node, turns_type_ref: String) -> void:
	skirmish = skirmish_ref
	turns_type = turns_type_ref

	if has_node("SkirmishUI/Panel/VboxContainer/Button1"):
		var Button1 = $SkirmishUI/Panel/VboxContainer/Button1
		Button1.text = turns_type_ref
	else:
		push_warning("skirmishui Button1 not found yet!")
	#print(skirmish)

	var layer := get_parent()
	if not layer or not (layer is CanvasLayer):
		push_warning("SkirmishUI: couldn't find a CanvasLayer parent.")
		return

	# --- Dynamic offset setup ---
	var tile_size: float = 64.0
	if "tile_size" in skirmish:
		tile_size = float(skirmish.tile_size)

	var columns: int = 8
	if "columns" in skirmish:
		columns = int(skirmish.columns)

	var board_width: float = ((columns * tile_size) + (tile_size * 0.5))

	layer.offset = Vector2(board_width, 0)


#func _ready():
	#Button1.text = turns_type
	

	
	#var button1 = $SkirmishUILayer/SkirmishUI/Panel/VBoxContainer/Button1
	#button1.pressed.connect(_on_button1_pressed)
#
#
#func _on_button1_pressed():
	#print("Button1 was pressed!")
	#skirmish._Randomize_Delete_Tiles()
