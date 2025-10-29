## GlobalInfo.gd (autoload singleton)
#extends Node
#
#var TileXSize: float
#var TileYSize: float
#
#var AllSquares: Dictionary = {}
#var HighlightedSquares: Array = []
#
#
#func ClearHighlights():
	#for square in HighlightedSquares:
		#if square and square.is_inside_tree():
			#var highlight = square.get_node("Highlight")
			#if highlight:
				#highlight.color.a = 0  # hide the overlay
	#HighlightedSquares.clear()
#
#func AddHighlightedSquare(square: Node, faction: String):
	#if not square:
		#return
#
	#var target_color = FactionColors.get(faction, {}).get("primary", Color(1,1,1))
	#var highlight = square.get_node("Highlight")
	#if not highlight:
		#print("failed to find Highlight overlay")
		#return
#
	## Fade overlay alpha to 1 with tween
	#var tween = get_tree().create_tween()
	#tween.tween_property(highlight, "color", Color(target_color.r, target_color.g, target_color.b, 1), 0.25)
#
	#if not HighlightedSquares.has(square):
		#HighlightedSquares.append(square)
		#print("added a Highlight to ", square)
#
#
#var Turn = 0
#var SavedNode = ""
#signal selected_piece_changed(new_piece)
#
#var _selected_piece: Node
#
#var SelectedPiece: Node:
	#set(value):
		#if _selected_piece == value:
			#ClearSelection()
		#else:
			#_selected_piece = value
			#emit_signal("selected_piece_changed", value)
			#print("Selected Piece: ", value)
	#get:
		#return _selected_piece
#
#func ClearSelection():
	#_selected_piece = null
	#print("Selection cleared")
	#emit_signal("selected_piece_changed", null)
#
## Dictionary of factions and their colors
#var FactionColors := {
	#"White": {"primary": Color(1, 1, 1, 1), "secondary": Color(0.1, 0.1, 0.1, 1)},
	#"Black": {"primary": Color(0.1, 0.1, 0.1, 1), "secondary": Color(0.7, 0.7, 0.7, 1)},
	#"Skins": {"primary": Color(0.9, 0.7, 0.6, 1), "secondary": Color(0.6, 0.4, 0.3, 1)},
	#"Red": {"primary": Color(0.76, 0, 0, 1), "secondary": Color(0.1, 0.1, 0.1, 1)},
	#"Blue": {"primary": Color(0.103, 0.405, 1, 1), "secondary": Color(0.9, 0.9, 0.9, 1)}
#}
	#
#
#var Pawn: CompressedTexture2D
#var Knight: CompressedTexture2D
#var Bishop: CompressedTexture2D
#var Rook: CompressedTexture2D
#var Queen: CompressedTexture2D
#var King: CompressedTexture2D
#
## Dictionary to look up textures by piece name
#var PieceTextures: Dictionary = {}
#var PieceMoves: Array = []
#
#
#
#func RandomizeColor(color: Color, percent: float) -> Color:
	## percent = 0.05 means ±5% variation
	#var r = clamp(color.r + randf_range(-percent, percent), 0.0, 1.0)
	#var g = clamp(color.g + randf_range(-percent, percent), 0.0, 1.0)
	#var b = clamp(color.b + randf_range(-percent, percent), 0.0, 1.0)
	#return Color(r, g, b, color.a)
#
	#
	#
#func _ready():
	## Hardcoded texture paths
	#PieceTextures = {
		#"Pawn": load("res://ChessTextures/WPawn.svg"),
		#"Knight": load("res://ChessTextures/WKnight.svg"),
		#"Bishop": load("res://ChessTextures/WBishop.svg"),
		#"Rook": load("res://ChessTextures/WRook.svg"),
		#"Queen": load("res://ChessTextures/WQueen.svg"),
		#"King": load("res://ChessTextures/WKing.svg")
	#}
	#
#
#func GenerateKnight():
	#var moves: Array = [
	#Vector2(2, 1),
	#Vector2(1, 2),
	#Vector2(-1, 2),
	#Vector2(-1, -2),
	#Vector2(-2, 1),
	#Vector2(-2, -1),
	#Vector2(1, -2),
	#Vector2(2, -1)
	#]
	#return moves
#
#func GenerateDiagonals(max_range: int ) -> Array:
	#var moves: Array = []
	#for i in range(1, max_range + 1):
		#moves.append(Vector2(i, i))     # Up-right
		#moves.append(Vector2(-i, i))    # Up-left
		#moves.append(Vector2(i, -i))    # Down-right
		#moves.append(Vector2(-i, -i))   # Down-left
	#return moves
	#
#func GenerateFlats(max_range: int ) -> Array:
	#var moves: Array = []
	#for i in range(1, max_range + 1):
		#moves.append(Vector2(i, 0))     # to right
		#moves.append(Vector2(-i, 0))     # to left
		#moves.append(Vector2(0, i))     # to up
		#moves.append(Vector2(0, -i))     # to down
	#return moves
	#
#func GenerateRings(max_range: int ) -> Array:
	#var moves: Array = []
	#for i in range(1, max_range + 1):
		#moves.append(Vector2(i, i))     # Up-right
		#moves.append(Vector2(-i, i))    # Up-left
		#moves.append(Vector2(i, -i))    # Down-right
		#moves.append(Vector2(-i, -i))   # Down-left
	#return moves
