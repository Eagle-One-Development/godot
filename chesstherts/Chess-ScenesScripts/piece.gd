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
var xy: Vector2i = Vector2i(0, 0)

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
var defense: int = 0

var MoveDeltaXY: Array[Vector2i] = []
var highlighted_tiles: Array = []
var tile_manager



func UpdateMobility(piece_input: String):
	print("Updating %s with %s mobility" % [self, piece_input])


func OnClick():
	#print("OnClick: ", faction)
	#print("OnClick: ", piece_type)
	#print("OnClick: ", self.global_position)
	#print("OnClick: PARENT ", parent_tile)
	print("OnClick: MoveDeltaXY = " + str(MoveDeltaXY))
	print(name, " is at location ", xy)
	#print("OnClick: SKIRMISH = ", skirmish)
	#print("OnClick: TILEMANAGER = ", tile_manager)
	#HighlightMoves()
	skirmish.SelectedPiece = self



#func Selected() -> void:
	#print(name, " got selected!")
	#print("OnClick: TILEMANAGER = ", tile_manager)

func Selected() -> void:
	print(name, " got selected!")
	if not tile_manager:
		push_warning("%s has no TileManager reference!" % name)
		return
	if MoveDeltaXY.is_empty():
		push_warning("%s has no MoveDeltaXY data!" % name)
		return
	if xy == null:
		push_warning("%s has no xy assigned!" % name)
		return
	# --- Get reachable tiles ---
	var reachable_tiles: Array = get_reachable_tiles()
	if reachable_tiles.is_empty():
		print("%s found no reachable tiles" % name)
		return
	# --- Highlight them ---
	highlighted_tiles.clear()
	for tile in reachable_tiles:
		if tile and tile.has_method("_highlight_for_faction"):
			tile._highlight_for_faction(faction)
			highlighted_tiles.append(tile)
		else:
			push_warning("Tile missing _highlight_for_faction: " + str(tile))
	print("Highlighted %d tiles for %s" % [highlighted_tiles.size(), name])


func deselected():
	print(name, " got unselected!")
	for tile in highlighted_tiles:
		if tile and tile.has_method("_reset_color"):
			tile._reset_color()
	highlighted_tiles.clear()


func get_reachable_tiles() -> Array:
	print("Getting reachable tiles for ", name, " at ", xy)
	var tiles: Array = []

	for delta in MoveDeltaXY:
		if typeof(delta) != TYPE_VECTOR2I:
			push_warning("%s invalid delta: %s" % [name, str(delta)])
			continue

		var target_xy: Vector2i = xy + delta
		var target_tile = tile_manager.get_tile(target_xy.x, target_xy.y)

		if target_tile:
			tiles.append(target_tile)
			print("  Found tile at ", target_xy)
		else:
			print("  No tile at ", target_xy)

	return tiles

#
#
func bootstrap(piece_input: String, tile_input: Vector2i, faction_input: String):
	load_assets()
	print("Bootstrapping %s for %s at %s" % [piece_input, faction_input, tile_input])
	#
	## --- Populate instance variables ---
	self.name = faction_input + piece_input
	self.faction = faction_input
	self.piece_type = piece_input
	self.xy = tile_input
	#self.global_position = parent_tile.global_position
	
	## --- Validate piece type ---
	if not PieceTextures.has(piece_input):
		push_error("Piece Type not found: %s" % piece_input)
		return
	# --- Assign texture ---
	var piece_texture: Texture2D = PieceTextures[piece_input]
	if has_node("SpriteMain"):
		$SpriteMain.texture = piece_texture
	else:
		push_warning("SpriteMain not found; applying texture to root node")
		self.texture = piece_texture
	#print("Bootstrap: %s texture assigned!" % piece_input)
	
	# --- Apply faction colors ---
	if not FactionColors.has(faction_input):
		push_error("Faction not found: %s" % faction_input)
		return
	#var colors = FactionColors[faction_input]
	var color_primary := FactionManager.get_color(faction, "primary")
	if has_node("SpriteMain"):
		$SpriteMain.modulate = color_primary
		#color_primary = color_primary
	else:
		self.modulate = color_primary

	if has_node("SpriteAccents"):
		var color_secondary := FactionManager.get_color(faction, "secondary")
		$SpriteAccents.modulate = color_secondary
		color_secondary = color_secondary
	else:
		push_warning("SpriteAccents not found; secondary color skipped")
	
	print("Bootstrap: %s colors applied!" % faction_input)
	#
	
	if has_node("SpriteAccents"):
		$SpriteAccents.texture = piece_texture
	else:
		push_warning("SpriteAccents not found; applying texture to root node")
	#print("Bootstrap: %s accent texture assigned!" % piece_input)

	# --- Assign moves based on piece type ---
	match piece_type:
		"Queen":
			self.MoveDeltaXY = GenerateDiags(7)
			self.MoveDeltaXY += GenerateAxis(7)
		"Knight":
			self.MoveDeltaXY = GenerateKnight()
		"Pawn":
			return
			#self.MoveDeltaXY = GenerateFlats(1)
		"Rook":
			self.MoveDeltaXY = GenerateAxis(7)
		"King":
			self.MoveDeltaXY = GenerateDiags(1)
			self.MoveDeltaXY += GenerateAxis(1)
		"Bishop":
			self.MoveDeltaXY = GenerateDiags(7)
		_:
			self.MoveDeltaXY = []  # default empty array for other pieces







# all of these need to consider obstructions, 
# Diag(7) needs each diag to be checking every square for obstructions

func GenerateKnight():
	var moves: Array[Vector2i] = [
	Vector2i(2, 1),
	Vector2i(1, 2),
	Vector2i(-1, 2),
	Vector2i(-1, -2),
	Vector2i(-2, 1),
	Vector2i(-2, -1),
	Vector2i(1, -2),
	Vector2i(2, -1)
	]
	return moves

func GenerateDiags(max_range: int ) -> Array:
	var moves: Array[Vector2i] = []
	for i in range(1, max_range + 1):
		moves.append(Vector2i(i, i))     # Up-right
		moves.append(Vector2i(-i, i))    # Up-left
		moves.append(Vector2i(i, -i))    # Down-right
		moves.append(Vector2i(-i, -i))   # Down-left
	return moves
	
func GenerateAxis(max_range: int ) -> Array:
	var moves: Array[Vector2i] = []
	for i in range(1, max_range + 1):
		moves.append(Vector2i(i, 0))     # to right
		moves.append(Vector2i(-i, 0))     # to left
		moves.append(Vector2i(0, i))     # to up
		moves.append(Vector2i(0, -i))     # to down
	return moves
	
func GenerateRings(max_range: int ) -> Array:
	var moves: Array[Vector2i] = []
	for i in range(1, max_range + 1):
		moves.append(Vector2i(i, i))     # Up-right
		moves.append(Vector2i(-i, i))    # Up-left
		moves.append(Vector2i(i, -i))    # Down-right
		moves.append(Vector2i(-i, -i))   # Down-left
	return moves

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
# Dictionary of factions and their colors
var FactionColors := {
	"White": {"primary": Color(1, 1, 1, 1), "secondary": Color(0.1, 0.1, 0.1, 1)},
	"Black": {"primary": Color(0.1, 0.1, 0.1, 1), "secondary": Color(0.7, 0.7, 0.7, 1)},
	"Skins": {"primary": Color(0.9, 0.7, 0.6, 1), "secondary": Color(0.6, 0.4, 0.3, 1)},
	"Red": {"primary": Color(0.76, 0, 0, 1), "secondary": Color(0.1, 0.1, 0.1, 1)},
	"Blue": {"primary": Color(0.103, 0.405, 1, 1), "secondary": Color(0.9, 0.9, 0.9, 1)}
}
	
