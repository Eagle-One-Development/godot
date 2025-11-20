extends Control

var skirmish: Node = null
var turns_type: String = "skirmish"
@export var tile_scene: Node = null
var tile_manager
@export var ui_x: int = 264

@onready var Main: Panel = $Main
@onready var Graveyard: Panel = $Main/Graveyard
@onready var Graveyard_Faction1: Panel = $Main/Graveyard/Faction1GY
@onready var Graveyard_Faction2: Panel = $Main/Graveyard/Faction2GY
@onready var Button1: Button = $Main/VBoxContainer/Button1
@onready var Button2: Button = $Main/VBoxContainer/Button2

func _ready() -> void:
	Button1.skirmishui = self
	Button2.skirmishui = self
	Button1.pressed.connect(_on_button1_pressed)
	Button2.pressed.connect(_on_button2_pressed)

func init(skirmish_ref: Node, turns_type_ref: String, tile_manager_ref: Node,) -> void:
	skirmish = skirmish_ref
	turns_type = turns_type_ref
	Button1.text = turns_type_ref
	tile_manager = tile_manager_ref
	#print("skirmshui tilemanger = ", tile_manager)

	var layer := get_parent()
	if not layer or not (layer is CanvasLayer):
		print("SkirmishUI: couldn't find a CanvasLayer parent.")
		return
	print("SkirmishUI: found a CanvasLayer parent!")
	print("skirmishui", tile_manager)
	var tile_size: float = 64.0
	if "tile_size" in skirmish:
		tile_size = float(skirmish.tile_size)

	var columns: int = 8
	if "columns" in skirmish:
		columns = int(skirmish.columns)

	var board_width: float = ((columns * tile_size) + (tile_size * 0.5))
	layer.offset = Vector2(board_width, 0)
	#var faction1 = tile_manager.faction1
	#var faction2 = tile_manager.faction2
	#Graveyard_Faction1.modulate = FactionManager.get_color(faction1)
	#Graveyard_Faction2.modulate = FactionManager.get_color(faction2)
	# setup GY

	

func _on_button1_pressed() -> void:
	print("Button1 was pressed!")
	skirmish._Randomize_Delete_Tiles()
	
func _on_button2_pressed() -> void:
	print("Button2 was pressed!")
	var piece = tile_manager.SelectedPiece
	AutoMove.piece_move(piece)

func _piece_to_graveyard(piece: Piece) -> void:
	piece.scale = Vector2(0.6, 0.6)

	var faction_graveyard: Array = FactionManager.get_nonplayable_pieces_by_faction(piece.faction)

	var index: int = max(0, faction_graveyard.size() - 1)

	var pieces_per_row: int = 8
	var col_width: int = 20
	var row_height: int = 40

	var row: int = index / pieces_per_row
	var col: int = index % pieces_per_row

	var offset: Vector2 = Vector2(col * col_width, row * row_height) + Vector2(15, 20)

	var base_pos: Vector2
	if piece.faction == tile_manager.faction1:
		base_pos = Graveyard_Faction1.get_screen_position()
	else:
		base_pos = Graveyard_Faction2.get_screen_position()

	piece.position = base_pos + offset
	piece.visible = true

	print(piece, " sent to GY (index=", index, " row=", row, " col=", col, ")")
