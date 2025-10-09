extends Sprite2D



# pieces texture are floating in top left of square... how to fix?

# Extra ablilities
var DoubleStart = true
var EnPassant = false

# Standard
var PieceColor: int

var Faction: String = "Skin"
var PieceType: String = "Pawn"
var XY: String = "X-Y"

var ColorPrimary: Color = Color(1, 1, 1)
var ColorSecondary: Color = Color(0.5, 0.5, 0.5)

var MoveDeltaXY: Array = []

var AttackSameAsMove: bool = true
var AttackDeltaXY: Array = []

var DefendSameAsAttack: bool = true
var DefendDeltaXY: Array = []

func UpdateMobility(piece_input: String):
	print("Updating %s with %s mobility" % [self, piece_input])

func HighlightMoves():
	if XY == "X-Y":
		push_warning("Piece does not have a valid XY position")
		return

	# clear any previous highlights
	
	GlobalInfo.ClearHighlights()

	var current_coords = XY.split("-")
	var curr_x = int(current_coords[0])
	var curr_y = int(current_coords[1])

	for delta in MoveDeltaXY:
		var target_x = curr_x + int(delta.x)
		var target_y = curr_y + int(delta.y)
		var square_name = "%d-%d" % [target_x, target_y]

		if GlobalInfo.AllSquares.has(square_name):
			var square_node = GlobalInfo.AllSquares[square_name]
			GlobalInfo.AddHighlightedSquare(square_node, Faction)

	
func OnClick():
	#print("OnClick: ", Faction)
	#print("OnClick: ", PieceType)
	#print("OnClick: MoveDeltaXY = " + str(MoveDeltaXY))
	#HighlightMoves()
	GlobalInfo.SelectedPiece = self


func Bootstrap(piece_input: String, square_input: String, faction_input: String):
	#print("Bootstrapping %s for %s at %s" % [piece_input, faction_input, square_input])
	
	# --- Populate instance variables ---
	self.Faction = faction_input
	self.PieceType = piece_input
	self.XY = square_input
	
	# --- Validate piece type ---
	if not GlobalInfo.PieceTextures.has(piece_input):
		push_error("Piece Type not found: %s" % piece_input)
		return
	
	# --- Assign moves based on piece type ---
	match PieceType:
		"Queen":
			self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(7)
			self.MoveDeltaXY += GlobalInfo.GenerateFlats(7)
		"Knight":
			self.MoveDeltaXY = GlobalInfo.GenerateKnight()
		"Pawn":
			self.MoveDeltaXY = GlobalInfo.GenerateFlats(1)
		"Rook":
			self.MoveDeltaXY = GlobalInfo.GenerateFlats(7)
		"King":
			self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(1)
			self.MoveDeltaXY += GlobalInfo.GenerateFlats(1)
		"Bishop":
			self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(7)
		_:
			self.MoveDeltaXY = []  # default empty array for other pieces
	
	# --- Assign texture ---
	var piece_texture: Texture2D = GlobalInfo.PieceTextures[piece_input]
	if has_node("SpriteMain"):
		$SpriteMain.texture = piece_texture
	else:
		push_warning("SpriteMain not found; applying texture to root node")
		self.texture = piece_texture
	#print("Bootstrap: %s texture assigned!" % piece_input)

	if has_node("SpriteAccents"):
		$SpriteAccents.texture = piece_texture
	else:
		push_warning("SpriteAccents not found; applying texture to root node")
	#print("Bootstrap: %s accent texture assigned!" % piece_input)

	# --- Apply faction colors ---
	if not GlobalInfo.FactionColors.has(faction_input):
		push_error("Faction not found: %s" % faction_input)
		return
	var colors = GlobalInfo.FactionColors[faction_input]
	if has_node("SpriteMain"):
		$SpriteMain.modulate = colors.primary
		ColorPrimary = colors.primary
	else:
		self.modulate = colors.primary

	if has_node("SpriteAccents"):
		$SpriteAccents.modulate = colors.secondary
		ColorSecondary = colors.secondary
	else:
		push_warning("SpriteAccents not found; secondary color skipped")
	
	#print("Bootstrap: %s colors applied!" % faction_input)

	# --- Parent to square ---
	if not GlobalInfo.AllSquares.has(square_input):
		push_error("Square not found: %s" % square_input)
		return
	var square = GlobalInfo.AllSquares[square_input]
	self.reparent(square)
	self.position = Vector2(GlobalInfo.TileXSize / 2, GlobalInfo.TileYSize / 2)
	
	#print("Successfully bootstrapped %s for %s at %s" % [piece_input, faction_input, square_input])
