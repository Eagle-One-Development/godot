# SKIRMISHUI
# need to make buttons appear
# the layout of SKIRMISHUI will be fixed, non dynamic


extends Control

var skirmish: Node = null
@export var ui_x: int = 800
#@export var ui_y: int = 200

func init(skirmish_ref: Node) -> void:
	skirmish = skirmish_ref
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
	
	#var button1 = $SkirmishUILayer/SkirmishUI/Panel/VBoxContainer/Button1
	#button1.pressed.connect(_on_button1_pressed)
#
#
#func _on_button1_pressed():
	#print("Button1 was pressed!")
	#skirmish._Randomize_Delete_Tiles()
