# skirmish!
# will recieve this input
############
# Vector2 grid size XY
# array piece layout row 1 and faction 1
# array piece layout row 2 and faction 1 
# array piece layout row 1 and faction 2
# array piece layout row 2 and faction 2 
#############
# will generate a minigame style skirmish!
#########
# this is a board, the peices, the proper colors
# this is UI = faction, timer, selected piece, resources, ability 1 2 3 , 
# ends with a finish!


# for now I will explore code here, then segment it into modular functions
# especially laying tiles, I want to try explore mode- touch last row and boom more board
extends Node2D

var tile_scene: PackedScene
var columns: int = 8
var rows: int = 8
var tile_size: float = 64

#var faction1: string = null
#var faction2: string = null #### soon! this will hold info used in the UI

var all_tiles: Array = []  # 2D array: tiles[x][y]
var highlighted_tiles: Array = []  # 2D array: tiles[x][y]

@onready var skirmishui = $SkirmishUILayer/SkirmishUI


func _ready():
	load_assets()
	inherit_skirmish_data()
	if tile_scene:
		generate_grid(columns, rows)

	else:
		push_warning("Tile scene not assigned!")
	skirmishui.init(self)  # give UI a reference to this Skirmish instance
	set_window_size()


func inherit_skirmish_data():
	var parent = get_parent()
	if not parent:
		push_warning("No parent found for Skirmish!")
		return
	# Only inherit if parent actually defines these exported variables
	if "tile_scene" in parent:
		tile_scene = parent.tile_scene
	if "columns" in parent:
		columns = parent.columns
	if "rows" in parent:
		rows = parent.rows
	if "tile_size" in parent:
		tile_size = parent.tile_size

func load_assets():
		# Hardcoded texture paths
	PieceTextures = {
		"Pawn": load("res://Chess-Assets/WPawn.svg"),
		"Knight": load("res://Chess-Assets/WKnight.svg"),
		"Bishop": load("res://Chess-Assets/WBishop.svg"),
		"Rook": load("res://Chess-Assets/WRook.svg"),
		"Queen": load("res://Chess-Assets/WQueen.svg"),
		"King": load("res://Chess-Assets/WKing.svg")
	}

func generate_grid(cols: int, rows: int):
	# Clear existing tiles
	for child in get_children():
		child.queue_free()
	all_tiles.clear()
	
	var offset = tile_size / 2  # half-tile offset

	# Initialize the 2D array
	for x in range(cols):
		all_tiles.append([])

		for y in range(rows):
			var tile = tile_scene.instantiate()
			add_child(tile)

			# Apply half-tile offset
			tile.position = Vector2(x * tile_size + offset, y * tile_size + offset)

			# Let the tile setup itself, name, color, assign dark
			tile.setup(x + 1, y + 1)
			print("setup (", x + 1, ", ", y + 1, ")")

			# Store reference
			all_tiles[x].append(tile)


func set_window_size() -> void:
	var width = int(columns * tile_size)
	var height = int(rows * tile_size)
	var ui_x = skirmishui.ui_x
	var ui_y = skirmishui.ui_y

	var window := get_window()
	if window:
		window.size = Vector2i(width + ui_x, height)
	else:
		push_warning("No active window found to resize.")

#
#func ClearHighlights():
	#for tile in highlighted_tiles:
		#if tile and tile.is_inside_tree():
			#var highlight = tile.get_node("Highlight")
			#if highlight:
				#highlight.color.a = 0  # hide the overlay
	#highlighted_tiles.clear()
#
#func AddHighlightedTile(tile: Node, faction: String):
	#if not tile:
		#return
#
	#var target_color = FactionColors.get(faction, {}).get("primary", Color(1,1,1))
	#var highlight = tile.get_node("Highlight")
	#if not highlight:
		#print("failed to find Highlight overlay")
		#return
#
	## Fade overlay alpha to 1 with tween
	#var tween = get_tree().create_tween()
	#tween.tween_property(highlight, "color", Color(target_color.r, target_color.g, target_color.b, 1), 0.25)
#
	#if not highlighted_tiles.has(tile):
		#highlighted_tiles.append(tile)
		#print("added a Highlight to ", tile)

#
#var Turn = 0
#var SavedNode = ""
signal selected_piece_changed(new_piece)

var _selected_piece: Node

var SelectedPiece: Node:
	set(value):
		if _selected_piece == value:
			ClearSelection()
		else:
			_selected_piece = value
			emit_signal("selected_piece_changed", value)
			print("Selected Piece: ", value)
	get:
		return _selected_piece

func ClearSelection():
	_selected_piece = null
	print("Selection cleared")
	emit_signal("selected_piece_changed", null)

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
var PieceTextures: Dictionary = {}
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
