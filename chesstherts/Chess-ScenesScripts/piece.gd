extends Node2D

#
#
# piece
## pieces texture are floating in top left of square... how to fix?
#
## Extra ablilities
#var DoubleStart = true
#var EnPassant = false
var skirmish = null
#
var faction: String = "Skin"
var piece_type: String = "Pawn"
#var tile: PackedStrng
var xy: String = "X-Y"

var _parent_tile: Node = null
var parent_tile: Node:
	get:
		return _parent_tile
	set(value):
		_parent_tile = value
		print("Piece parent_tile set to:", value)

#
var color_primary: Color = Color(1, 1, 1)
var color_secondary: Color = Color(0.5, 0.5, 0.5)
#

var PieceTextures: Dictionary = {}



func UpdateMobility(piece_input: String):
	print("Updating %s with %s mobility" % [self, piece_input])

	#
func OnClick():
	print("OnClick: ", faction)
	print("OnClick: ", piece_type)
	print("OnClick: ", self.global_position)
	print("OnClick: PARENT ", parent_tile)
	#print("OnClick: MoveDeltaXY = " + str(MoveDeltaXY))
	#HighlightMoves()
	#GlobalInfo.SelectedPiece = self
#
#
func bootstrap(piece_input: String, tile_input: String, faction_input: String):
	load_assets()
	print("Bootstrapping %s for %s at %s" % [piece_input, faction_input, tile_input])
	#
	## --- Populate instance variables ---
	self.faction = faction_input
	self.piece_type = piece_input
	self.xy = tile_input
	#self.global_position = parent_tile.global_position
	#
	## --- Validate piece type ---
	#if not GlobalInfo.PieceTextures.has(piece_input):
		#push_error("Piece Type not found: %s" % piece_input)
		#return
	#
	## --- Assign moves based on piece type ---
	#match PieceType:
		#"Queen":
			#self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(7)
			#self.MoveDeltaXY += GlobalInfo.GenerateFlats(7)
		#"Knight":
			#self.MoveDeltaXY = GlobalInfo.GenerateKnight()
		#"Pawn":
			#self.MoveDeltaXY = GlobalInfo.GenerateFlats(1)
		#"Rook":
			#self.MoveDeltaXY = GlobalInfo.GenerateFlats(7)
		#"King":
			#self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(1)
			#self.MoveDeltaXY += GlobalInfo.GenerateFlats(1)
		#"Bishop":
			#self.MoveDeltaXY = GlobalInfo.GenerateDiagonals(7)
		#_:
			#self.MoveDeltaXY = []  # default empty array for other pieces
	#
	# --- Assign texture ---
	var piece_texture: Texture2D = PieceTextures[piece_input]
	if has_node("SpriteMain"):
		$SpriteMain.texture = piece_texture
	else:
		push_warning("SpriteMain not found; applying texture to root node")
		self.texture = piece_texture

	#print("Bootstrap: %s texture assigned!" % piece_input)

	#if has_node("SpriteAccents"):
		#$SpriteAccents.texture = piece_texture
	#else:
		#push_warning("SpriteAccents not found; applying texture to root node")
	##print("Bootstrap: %s accent texture assigned!" % piece_input)
#
	## --- Apply faction colors ---
	#if not GlobalInfo.FactionColors.has(faction_input):
		#push_error("Faction not found: %s" % faction_input)
		#return
	#var colors = GlobalInfo.FactionColors[faction_input]
	#if has_node("SpriteMain"):
		#$SpriteMain.modulate = colors.primary
		#ColorPrimary = colors.primary
	#else:
		#self.modulate = colors.primary
#
	#if has_node("SpriteAccents"):
		#$SpriteAccents.modulate = colors.secondary
		#ColorSecondary = colors.secondary
	#else:
		#push_warning("SpriteAccents not found; secondary color skipped")
	#
	#print("Bootstrap: %s colors applied!" % faction_input)
#
	## --- Parent to square ---
	#if not GlobalInfo.AllSquares.has(square_input):
		#push_error("Square not found: %s" % square_input)
		#return
	#var square = GlobalInfo.AllSquares[square_input]
	#self.reparent(square)
	#self.position = Vector2(GlobalInfo.TileXSize / 2, GlobalInfo.TileYSize / 2)
	#
	##print("Successfully bootstrapped %s for %s at %s" % [piece_input, faction_input, square_input])


func load_assets():
	PieceTextures = {
		"Pawn": load("res://Chess-Assets/WPawn.svg"),
		"Knight": load("res://Chess-Assets/WKnight.svg"),
		"Bishop": load("res://Chess-Assets/WBishop.svg"),
		"Rook": load("res://Chess-Assets/WRook.svg"),
		"Queen": load("res://Chess-Assets/WQueen.svg"),
		"King": load("res://Chess-Assets/WKing.svg")
	}
