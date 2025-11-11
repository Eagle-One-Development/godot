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
# this minigame is defines the starting factors:
# # # # window size, 2 factions and starting pieces, turn type

# all actual gameplay is determined by the tile_manager

#########
# this is a board, the peices, the proper colors
# this is UI = faction, timer, selected piece, resources, ability 1 2 3 , 
# ends with a finish!


# S K I R M I S H #
extends Node2D

# PARENT KNOWLEDGE # PARENT KNOWLEDGE # PARENT KNOWLEDGE 
var menu: Node = null
var turns_type: String = "skirmish" #strict_turns dynamic_turns
# SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE 
@export var piece_scene: PackedScene # this points to piece.tscn
@export var tile_scene: PackedScene # this points to piece.tscn
var columns: int = 8
var rows: int = 8
var board_center := Vector2(columns * 0.5, rows * 0.5)
var tile_size: float = 64

#var all_tiles_xy: Array = []  # 2D array: tiles[x][y]
#var all_t: Dictionary = {}         # key: Vector2i(x, y), value: tile
#var coord_lookup: Dictionary = {}        # key: tile, value: Vector2i(x, y)
#
#var highlighted_tiles: Array = []  # 2D array: tiles[x][y]

@onready var skirmishui = $SkirmishUILayer/SkirmishUi
@onready var tile_manager = TileManager.new()


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

func skirmish_instantiate_pieces():
	var board_center := Vector2(columns * 0.5, rows * 0.5 + 1)
	print("skirmish_instantiate_pieces.board_center = ", board_center)

	spawn_faction_row(board_center.y - 3, board_center.x, menu.faction1row1, menu.faction1)
	spawn_faction_row(board_center.y - 4, board_center.x, menu.faction1row2, menu.faction1)

	spawn_faction_row(board_center.y + 2, board_center.x, menu.faction2row1, menu.faction2)
	spawn_faction_row(board_center.y + 3, board_center.x, menu.faction2row2, menu.faction2)


func spawn_faction_row(row_offset: int, column: int, pieces: Array, faction: String) -> void:
	if pieces.is_empty():
		#push_warning("No pieces to spawn for faction: " + faction)
		return

	var total_pieces: int = pieces.size()
	var board_center_x: float = columns / 2 + 1
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
	skirmish_instantiate_pieces()


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
	
