# gameplayui.gd
extends Window

var board_ref: Node = null
var turn: String = ""
var SelectedPiece = null
@onready var label = $VBoxContainer/Label



func _ready() -> void:
	if board_ref != null:
		print("UI window created for board:", board_ref.name)
	GlobalInfo.selected_piece_changed.connect(_on_selected_piece_changed)
	label.text = "game start; nothing selected"

func _on_selected_piece_changed(new_piece: Node):
	var SelectedPiece = new_piece
	print("GameplayUI calls _on_selected_piece_changed:", SelectedPiece)

	if SelectedPiece:
		# Access the exported vars directly
		var faction = str(SelectedPiece.Faction)
		var piece_type = str(SelectedPiece.PieceType)
		label.text = faction + " " + piece_type
	else:
		label.text = "No piece selected"


		
func Init(board: Node) -> void:
	board_ref = board
	print("UI window created for board:", board_ref)
	title = "Game UI"
	always_on_top = true
	exclusive = false
	position = Vector2(1200, 100)
	size = Vector2(400, 600)
	show()
