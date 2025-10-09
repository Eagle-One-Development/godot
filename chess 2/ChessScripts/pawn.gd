extends Sprite2D

# Extra ablilities
var DoubleStart = true
var EnPassant = false

# Standard
var PieceColor: int
var Faction: String = "Skin"
var PieceType: String = "Pawn"
var XY: String = "X-Y"

func Bootstrap(piece_input: String, square_input: String, faction_input: String):
	# give type
	# color piece
	# put on XY
	

	if not GlobalInfo.FactionColors.has(piece_input):
		push_error("piece type not found: %s" % piece_input)
		return
	var piece_texture = GlobalInfo.PieceTextures[piece_input]
	self.texture = piece_texture
	if not GlobalInfo.FactionColors.has(faction_input):
		push_error("Faction not found: %s" % faction_input)
		return
	var colors = GlobalInfo.FactionColors[faction_input]
	if has_node("Sprite"):
		$Sprite.modulate = colors.primary
	if has_node("Outline"):
		$Outline.modulate = colors.secondary
		
		
			# Move piece to the square
	var square_node = get_node_or_null(square_input)
	if square_node:
		self.position = square_node.position
		square_node.add_child(self)
	else:
		push_error("Square not found: %s" % square_input)
