# S K I R M I S H #
# S K I R M I S H #
# S K I R M I S H #

# SkirmishUI is added to Skirmish.scene tree manually.
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

# S K I R M I S H #
extends Node2D

var menu: Node = null
#	print(menu_instance.faction1row1)
	
@export var piece_scene: PackedScene # this points to piece.tscn
@export var tile_scene: PackedScene # this points to piece.tscn
var columns: int = 8
var rows: int = 8
var tile_size: float = 64

#var faction1: string = null
#var faction2: string = null #### soon! this will hold info used in the UI

var all_tiles_xy: Array = []  # 2D array: tiles[x][y]
var all_t: Dictionary = {}         # key: Vector2i(x, y), value: tile
var coord_lookup: Dictionary = {}        # key: tile, value: Vector2i(x, y)

var highlighted_tiles: Array = []  # 2D array: tiles[x][y]

@onready var skirmishui = $SkirmishUILayer/SkirmishUI




var tiles = TileManager.new()
# --- Inner TileManager class ---
class TileManager:
	var tile_lookup: Dictionary = {}   # Vector2i → Tile
	var coord_lookup: Dictionary = {}  # Tile → Vector2i
	var tile_size: float = 0.0

	func setup_grid(tile_scene: PackedScene, parent: Node, cols: int, rows: int, _tile_size: float):
		clear()
		tile_size = _tile_size
		var offset = tile_size / 2

		for x in range(cols):
			for y in range(rows):
				var tile = tile_scene.instantiate()
				parent.add_child(tile)
				tile.skirmish = parent
				tile.position = Vector2(x * tile_size + offset, y * tile_size + offset)
				tile.setup(x + 1, y + 1)

				var coords = Vector2i(x, y)
				tile_lookup[coords] = tile
				coord_lookup[tile] = coords

	func clear():
		for tile in tile_lookup.values():
			if is_instance_valid(tile):
				tile.queue_free()
		tile_lookup.clear()
		coord_lookup.clear()
		
	func get_info_of(value):
		# If given a coordinate (Vector2i), return the tile
		if typeof(value) == TYPE_VECTOR2I:
			return tile_lookup.get(value, null)
	
		# If given a tile (Node), return the coordinates
		elif typeof(value) == TYPE_OBJECT and coord_lookup.has(value):
			return coord_lookup[value]
	
		# Otherwise, invalid input
		push_warning("get_info_of() expects a Vector2i or a Tile instance.")
		return null
# --- Full structured lookup (returns both) ---
	func get_dict_of(value) -> Dictionary:
		var info := {
			"tile": null,
			"coords": null
		}

		if typeof(value) == TYPE_VECTOR2I:
			info.coords = value
			info.tile = tile_lookup.get(value, null)
			return info

		elif typeof(value) == TYPE_OBJECT and coord_lookup.has(value):
			info.tile = value
			info.coords = coord_lookup[value]
			return info

		push_warning("get_dict_of() expects a Vector2i or Tile instance.")
		return info

	func get_tile(x: int, y: int) -> Node:
		return tile_lookup.get(Vector2i(x, y), null)

	func get_coords(tile: Node) -> Vector2i:
		return coord_lookup.get(tile, Vector2i(-1, -1))

	func get_all_tiles() -> Array:
		return tile_lookup.values()

	func remove_tile(tile: Node):
		var coords = coord_lookup.get(tile)
		if coords:
			tile_lookup.erase(coords)
		coord_lookup.erase(tile)
		if is_instance_valid(tile):
			tile.queue_free()


#func load_assets():
		## Hardcoded texture paths
	#PieceTextures = {
		#"Pawn": load("res://Chess-Assets/WPawn.svg"),
		#"Knight": load("res://Chess-Assets/WKnight.svg"),
		#"Bishop": load("res://Chess-Assets/WBishop.svg"),
		#"Rook": load("res://Chess-Assets/WRook.svg"),
		#"Queen": load("res://Chess-Assets/WQueen.svg"),
		#"King": load("res://Chess-Assets/WKing.svg")
	#}


func set_window_size() -> void:
	var width = int(columns * tile_size)
	var height = int(rows * tile_size)
	var ui_x = skirmishui.ui_x
#	var ui_y = skirmishui.ui_y

	var window := get_window()
	if window:
		window.size = Vector2i(width + ui_x, height)
	else:
		push_warning("No active window found to resize.")
	#print("all_tiles type:", typeof(all_tiles))
	#print("first element type:", typeof(all_tiles[0]) if all_tiles.size() > 0 else "none")


func instantiate_pieces():
	# Faction 1
	spawn_faction_row(1, menu.faction1row1, menu.faction1)
	spawn_faction_row(0, menu.faction1row2, menu.faction1)

	# Faction 2 (top of board)
	spawn_faction_row(6, menu.faction2row1, menu.faction2)
	spawn_faction_row(7, menu.faction2row2, menu.faction2)


func spawn_faction_row(row: int, pieces: Array, faction: String):
	for x in range(pieces.size()):
		var tile = tiles.get_tile(x, row)
		if not tile:
			push_warning("Tile not found at: ", x, row)
			continue
		
		var piece_instance = piece_scene.instantiate()
		tile.add_child(piece_instance)

		# Center piece inside tile
		piece_instance.position = Vector2.ZERO

		# Set references
		piece_instance._parent_tile = tile
		piece_instance.skirmish = self
		tile.occupant = piece_instance

		# Bootstrap the piece
		piece_instance.bootstrap(pieces[x], tile.name, faction)

		print("Spawned piece ", pieces[x], " on tile ", tile.name, 
			  " local_pos: ", piece_instance.position,
			  " parent: ", piece_instance.get_parent())


func _ready():
	#load_assets()
	inherit_skirmish_data()
	if tile_scene:
		#tiles = TileManager.new()
		tiles.setup_grid(tile_scene, self, columns, rows, tile_size)
	else:
		push_warning("Tile scene not assigned!")
	skirmishui.init(self)  # give UI a reference to this Skirmish instance
	set_window_size()
	instantiate_pieces()


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
	

func _Randomize_Delete_Tiles():
	print("trying to random delete")

	# 1. Check if we have any tiles
	if tiles.tile_lookup.is_empty():
		print("no tiles found")
		return

	# 2. Pick a random coordinate key from the dictionary
	var random_coords = tiles.tile_lookup.keys().pick_random()
	var random_tile = tiles.tile_lookup[random_coords]

	# 3. Act on the tile
	print("Randomly disabled tile at:", random_coords, "|", random_tile)

	random_tile.playable = false

	# Optional: remove the tile entirely from the grid
	# tiles.remove_tile(random_tile)
