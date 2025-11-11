extends Control

var skirmish: Node = null
var turns_type: String = "skirmish"
@export var ui_x: int = 264

@onready var Button1: Button = $Panel/VBoxContainer/Button1

func _ready() -> void:
	Button1.pressed.connect(_on_button1_pressed)

func init(skirmish_ref: Node, turns_type_ref: String) -> void:
	skirmish = skirmish_ref
	turns_type = turns_type_ref
	Button1.text = turns_type_ref

	var layer := get_parent()
	if not layer or not (layer is CanvasLayer):
		print("SkirmishUI: couldn't find a CanvasLayer parent.")
		return
	print("SkirmishUI: found a CanvasLayer parent!")

	var tile_size: float = 64.0
	if "tile_size" in skirmish:
		tile_size = float(skirmish.tile_size)

	var columns: int = 8
	if "columns" in skirmish:
		columns = int(skirmish.columns)

	var board_width: float = ((columns * tile_size) + (tile_size * 0.5))
	layer.offset = Vector2(board_width, 0)

func _on_button1_pressed() -> void:
	print("Button1 was pressed!")
	skirmish._Randomize_Delete_Tiles()
