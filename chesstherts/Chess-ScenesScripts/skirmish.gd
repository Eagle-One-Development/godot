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
var turns_type: String = "skirmish" #strict_turns dynamic_turns
	
@export var piece_scene: PackedScene # this points to piece.tscn
@export var tile_scene: PackedScene # this points to piece.tscn
var columns: int = 8
var rows: int = 8
var board_center := Vector2(columns * 0.5, rows * 0.5)
var tile_size: float = 64

#var faction1: string = null
#var faction2: string = null #### soon! this will hold info used in the UI

var all_tiles_xy: Array = []  # 2D array: tiles[x][y]
var all_t: Dictionary = {}         # key: Vector2i(x, y), value: tile
var coord_lookup: Dictionary = {}        # key: tile, value: Vector2i(x, y)

var highlighted_tiles: Array = []  # 2D array: tiles[x][y]

@onready var skirmishui = $SkirmishUILayer/SkirmishUI




#var tiles = TileManager.new() #### old name for tile manager
var tile_manager = TileManager.new()
# --- Inner TileManager class ---
class TileManager:
	var tile_lookup: Dictionary = {}   # give Vector2i → Tile scene
	var coord_lookup: Dictionary = {}  # give Tile scene → Vector2i
	var tile_size: float = 0.0
	var faction1_row1_offset: Vector2i = Vector2i(0, 0) # bottom of screen
	var faction2_row1_offset: Vector2i = Vector2i(0, 0) # top of screen

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
				tile.tile_manager = self
				tile.setup(x + 1, y + 1)

				var coords = Vector2i(x, y)
				tile.xy = coords
				tile_lookup[coords] = tile
				coord_lookup[tile] = coords
	# establish spawn points for faction1 and faction2
	# locate XY center of board, then do +-2  rows for empty

	func clear():
		for tile in tile_lookup.values():
			if is_instance_valid(tile):
				tile.queue_free()
		tile_lookup.clear()
		coord_lookup.clear()
		
	func get_info_of(value): # flexible input lookup VECTOR2I OR OBJECT
		# If given a coordinate (Vector2i), return the tile
		if typeof(value) == TYPE_VECTOR2I:
			return tile_lookup.get(value, null)
	
		# If given a tile (Node), return the coordinates
		elif typeof(value) == TYPE_OBJECT and coord_lookup.has(value):
			return coord_lookup[value]
	
		# Otherwise, invalid input
		#push_warning("get_info_of() expects a Vector2i or a Tile instance.")
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

		#push_warning("get_dict_of() expects a Vector2i or Tile instance.")
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
		print()
		#push_warning("No active window found to resize.")
	#print("all_tiles type:", typeof(all_tiles))
	#print("first element type:", typeof(all_tiles[0]) if all_tile_manager.size() > 0 else "none")


func instantiate_pieces():
	var board_center := Vector2(columns * 0.5, rows * 0.5)

	spawn_faction_row(board_center.y - 3, board_center.x, menu.faction1row1, menu.faction1)
	spawn_faction_row(board_center.y - 4, board_center.x, menu.faction1row2, menu.faction1)

	spawn_faction_row(board_center.y + 2, board_center.x, menu.faction2row1, menu.faction2)
	spawn_faction_row(board_center.y + 3, board_center.x, menu.faction2row2, menu.faction2)


func spawn_faction_row(row_offset: int, column: int, pieces: Array, faction: String) -> void:
	if pieces.is_empty():
		#push_warning("No pieces to spawn for faction: " + faction)
		return

	var total_pieces: int = pieces.size()
	var board_center_x: float = columns / 2.0
	var start_x: int = int(board_center_x - total_pieces / 2.0)

	for i in range(total_pieces):
		var raw_piece = pieces[i]
		if raw_piece == null or String(raw_piece).strip_edges() == "":
			#push_warning("Skipping invalid piece at index %d for faction %s" % [i, faction])
			continue

		var piece_type: String = String(raw_piece)
		var x: int = start_x + i
		var tile := tile_manager.get_tile(x, row_offset)
		if not tile:
			#push_warning("Tile not found at: ", x, row_offset)
			continue

		tile.spawn_piece(piece_type, faction)
		#print("Spawned", piece_type, "for", faction, "at tile:", tile.name, "(x:", x, "y:", row_offset, ")")


func _ready():
	#load_assets()
	inherit_skirmish_data()
	if tile_scene:
		#tiles = TileManager.new()
		tile_manager.setup_grid(tile_scene, self, columns, rows, tile_size)
	else:
		print()
		#push_warning("Tile scene not assigned!")
	skirmishui.init(self, "skirmish")  # give UI a reference to this Skirmish instance
	skirmishui.turns_type = turns_type
	#print("skirmish ", turns_type)
	set_window_size()
	instantiate_pieces()


func inherit_skirmish_data():
	var parent = get_parent()
	if not parent:
		#push_warning("No parent found for Skirmish!")
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
	#if not highlighted_tile_manager.has(tile):
		#highlighted_tile_manager.append(tile)
		#print("added a Highlight to ", tile)

#
#var Turn = 0
#var SavedNode = ""


#func RandomizeColor(color: Color, percent: float) -> Color:
	## percent = 0.05 means ±5% variation
	#var r = clamp(color.r + randf_range(-percent, percent), 0.0, 1.0)
	#var g = clamp(color.g + randf_range(-percent, percent), 0.0, 1.0)
	#var b = clamp(color.b + randf_range(-percent, percent), 0.0, 1.0)
	#return Color(r, g, b, color.a)
	#
signal selected_piece_changed(new_piece)

var _selected_piece: Node

var SelectedPiece: Node:
	set(value):
		# Case 1: clicking same piece again = deselect
		if _selected_piece == value:
			ClearSelection()
			return

		# Case 2: another piece is already selected → deselect it first
		if _selected_piece and _selected_piece.has_method("deselected"):
			_selected_piece.deselected()

		# Case 3: set the new selection
		_selected_piece = value
		
		if _selected_piece and _selected_piece.has_method("selected"):
			_selected_piece.selected()

		#print("Selected Piece: ", _selected_piece)
		emit_signal("selected_piece_changed", _selected_piece)
	get:
		return _selected_piece



func ClearSelection():
	if _selected_piece and _selected_piece.has_method("deselected"):
		_selected_piece.deselected()
	_selected_piece = null
	#print("Selection cleared")
	emit_signal("selected_piece_changed", null)
	
	
func move_selected_piece(piece: Node):
	print(piece, " is moving!")
	piece.move()
	
	
func _Randomize_Delete_Tiles():
	print("trying to random delete")

	# 1. Check if we have any tiles
	if tile_manager.tile_lookup.is_empty():
		print("no tiles found")
		return

	# 2. Pick a random coordinate key from the dictionary
	var random_coords = tile_manager.tile_lookup.keys().pick_random()
	var random_tile = tile_manager.tile_lookup[random_coords]

	# 3. Act on the tile
	print("Randomly disabled tile at:", random_coords, "|", random_tile)

	random_tile.playable = false

	# Optional: remove the tile entirely from the grid
	# tile_manager.remove_tile(random_tile)
