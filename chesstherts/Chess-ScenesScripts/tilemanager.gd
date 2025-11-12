# tilemanager.gd
extends Node
class_name TileManager

var tile_lookup: Dictionary = {}   # Vector2i → Tile scene
var coord_lookup: Dictionary = {}  # Tile scene → Vector2i
var tile_size: float = 0.0
var skirmish: Node = null

var _highlighted_tiles: Array = []
var highlighted_tiles: Array:
	set(value):
		#print("highlighted_tiles input = ", value)
		# normalize input
		if value == null:
			value = []
		elif typeof(value) != TYPE_ARRAY:
			value = [value]

		# tiles to remove (currently highlighted but not in new input)
		for tile in _highlighted_tiles:
			if is_instance_valid(tile) and not value.has(tile):
				if tile.has_method("_reset_color"):
					tile._reset_color()
					tile._flashing = false

		# tiles to add (in new input but not currently highlighted)
		for tile in value:
			if is_instance_valid(tile) and not _highlighted_tiles.has(tile):
				if SelectedPiece and is_instance_valid(SelectedPiece):
					if tile.has_method("_highlight_for_faction"):
						tile._highlight_for_faction(SelectedPiece.faction)
						#print("highlighted_tiles _highlight_for_faction = ", SelectedPiece.faction, " at ", tile)

		# store new highlighted_tiles
		_highlighted_tiles = value.duplicate()

	get:
		return _highlighted_tiles


var faction1_row1_offset: Vector2i = Vector2i(0, 0)
var faction2_row1_offset: Vector2i = Vector2i(0, 0)


func setup_grid(tile_scene: PackedScene, parent: Node, cols: int, rows: int, _tile_size: float):
	clear()
	skirmish = parent
	tile_size = _tile_size
	var offset = tile_size / 2

	for x in range(cols):
		for y in range(rows):
			var tile = tile_scene.instantiate()
			parent.add_child(tile)
			tile.skirmish = parent
			tile.position = Vector2(x * tile_size + offset, y * tile_size + offset)
			tile.tile_manager = self
			tile.connect("clicked_tile", Callable(self, "_on_tile_clicked"))
			tile.setup(x + 1, y + 1)

			var coords = Vector2i(x + 1, y + 1)
			#tile.xy = coords
			tile_lookup[coords] = tile
			coord_lookup[tile] = coords


func clear():
	for tile in tile_lookup.values():
		if is_instance_valid(tile):
			tile.queue_free()
	tile_lookup.clear()
	coord_lookup.clear()


func get_info_of(value):
	if typeof(value) == TYPE_VECTOR2I:
		return tile_lookup.get(value, null)
	elif typeof(value) == TYPE_OBJECT and coord_lookup.has(value):
		return coord_lookup[value]
	return null


func get_dict_of(value) -> Dictionary:
	var info := {"tile": null, "coords": null}
	if typeof(value) == TYPE_VECTOR2I:
		info.coords = value
		info.tile = tile_lookup.get(value, null)
	elif typeof(value) == TYPE_OBJECT and coord_lookup.has(value):
		info.tile = value
		info.coords = coord_lookup[value]
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


################################################
# CODE INVOLVING PIECES # CODE INVOLVING PIECES 
################################################
# CODE INVOLVING PIECES # CODE INVOLVING PIECES 
################################################
# CODE INVOLVING PIECES # CODE INVOLVING PIECES 
################################################
# CODE INVOLVING PIECES # CODE INVOLVING PIECES 
################################################
# CODE INVOLVING PIECES # CODE INVOLVING PIECES 

signal selected_piece_changed(new_piece)

var _selected_piece: Node

var SelectedPiece: Node:
	set(value):
		# Case 1: clicking same piece again = deselect
		if _selected_piece == value:
			print("double clicked ", _selected_piece, " so we deselect")
			ClearSelection()
			return

		# Case 2: another piece is already selected → deselect it first
		if _selected_piece and _selected_piece.has_method("deselected"):
			print("currently selected ", _selected_piece, " is deselected for new selection:")
			_selected_piece.deselected()

		# Case 3: set the new selection
		print("selected ", value)
		_selected_piece = value
		
		if _selected_piece and _selected_piece.has_method("selected"):
			_selected_piece.selected()

		
		emit_signal("selected_piece_changed", _selected_piece)
	get:
		return _selected_piece
		#highlighted_tiles = SelectedPiece.get_reachable_tiles()
	#print(highlighted_tiles)


func ClearSelection():
	if _selected_piece and _selected_piece.has_method("deselected"):
		_selected_piece.deselected()
	_selected_piece = null
	highlighted_tiles = []
	print("CLEAR SELECTION TILES = ",highlighted_tiles)
	#print("Selection cleared")
	emit_signal("selected_piece_changed", null)

######### clicking tile
#do we select? do we clear select? 
#do we selectedpiece.move?
func _on_tile_clicked(tile) -> void:
	if SelectedPiece and tile in highlighted_tiles:
		# Move the piece to this tile
		SelectedPiece.move(tile)
	elif tile.occupant:
		# Tile has a piece on it
		if tile.occupant.has_method("OnClick"):
			tile.occupant.OnClick()
		else:
			print("Occupant has no OnClick method!")
	else:
		# Tile is empty and not a highlighted move
		ClearSelection()
		print("_on_tile_clicked is empty, cleared selection: ", tile)

		
func _reset_highlighted_tiles():
	for tile in highlighted_tiles:
		if is_instance_valid(tile):
			tile._ramp_to_color(tile.origin_color, 0.4)
			tile._flashing = false
