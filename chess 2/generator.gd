extends Control

@export var Faction0: String = "Skins"
@export var Faction1: String = "Black"

@export var BoardXSize = 8
@export var BoardYSize = 8
@export var ColorSquareDark: Color = Color(0.1, 0.1, 0.1, 1)
@export var ColorSquareLight: Color = Color(1, 1, 1, 1)
@export var ColorSquareSpecial: Color = Color(1, 0, 0, 0.1)
@export var ColorSquareSpecial2: Color = Color(0, 0.4, 0, 1) 

@export var TileXSize: float = 70
@export var TileYSize: float = 70
@export var TileColorDriftPercent: float = 0.05

@export var PlayRegularGame: bool = true

signal SendLocation(Location: String)

@export var Piece: PackedScene = preload("res://ChessScenes/Piece.tscn")
@onready var SquareScene: PackedScene = preload("res://ChessScenes/Square.tscn")


var SelectedPiece: Node = null

# --- Helpers ---
func RandomizeColor(base: Color, drift_percent: float) -> Color:
	var r = clamp(base.r + randf_range(-drift_percent, drift_percent), 0, 1)
	var g = clamp(base.g + randf_range(-drift_percent, drift_percent), 0, 1)
	var b = clamp(base.b + randf_range(-drift_percent, drift_percent), 0, 1)
	return Color(r, g, b, base.a)

func get_pieces_in_square(square_node: Node) -> Array:
	var pieces: Array = []
	if square_node == null:
		return pieces
	for child in square_node.get_children():
		if child.has_method("Bootstrap") or child.has_method("OnClick"):
			pieces.append(child)
	return pieces

func has_piece(square_node: Node) -> bool:
	return get_pieces_in_square(square_node).size() > 0

func ClearSelection():
	SelectedPiece = null
	print("Selection cleared")

# --- Spawn a piece on a square ---
func SpawnPieceAtSquare(piece_type: String, square_node: Node, faction: String) -> Node:
	#print("attempting SpawnPieceAtSquare")
	var piece_scene: PackedScene = preload("res://ChessScenes/Piece.tscn")
	var piece_instance = piece_scene.instantiate()
	piece_instance.name = "%s_%s" % [faction, piece_type]

	# Add piece after overlay
	square_node.add_child(piece_instance)
	piece_instance.move_to_front()
	piece_instance.position = Vector2(TileXSize/2, TileYSize/2)

	if piece_instance.has_method("Bootstrap"):
		piece_instance.Bootstrap(piece_type, square_node.name, faction)
	else:
		push_error("Piece missing Bootstrap: %s" % piece_instance.name)

	#print("Spawned %s at %s" % [piece_instance.name, square_node.name])
	return piece_instance
# --- Board generation ---

func _ready() -> void:
	GlobalInfo.TileXSize = TileXSize
	GlobalInfo.TileYSize = TileYSize

	var board_width_px = BoardXSize * TileXSize
	var board_height_px = BoardYSize * TileYSize
	get_window().size = Vector2i(board_width_px, board_height_px)

	for y in range(BoardYSize):
		for x in range(BoardXSize):
			var display_x = x + 1
			var display_y = y + 1

			# --- Instantiate Square Scene ---
			var square_instance = SquareScene.instantiate()
			square_instance.name = "%d-%d" % [display_x, display_y]
			GlobalInfo.AllSquares[square_instance.name] = square_instance

			# Set size dynamically based on generator
			square_instance.SetTileSize(Vector2(TileXSize, TileYSize))

			# Checkerboard color
			var base_color = ColorSquareLight if (x + y) % 2 == 0 else ColorSquareDark
			base_color = RandomizeColor(base_color, TileColorDriftPercent)
			square_instance.SetBaseColor(base_color)
			square_instance.set_meta("original_color", base_color)

			# Position
			square_instance.pivot_offset = Vector2.ZERO
			var top_left_pos = Vector2(x * TileXSize, y * TileXSize)  # simple top-left layout
			square_instance.position = top_left_pos

			# Connect click signal
			square_instance.connect("gui_input", Callable(self, "_on_square_gui_input").bind(display_x, display_y))

			# Add to scene
			add_child(square_instance)

	# Spawn pieces using your offsets
	RegularGameOffset()

# --- Floating UI Window ---
	var ui_scene: PackedScene = load("res://gameplayui.tscn")
	if not ui_scene:
		push_error("Failed to load UI scene")
		return

	var ui_window = ui_scene.instantiate()
	get_window().call_deferred("add_child", ui_window)
	ui_window.Init(self)

# --- Arrange windows side-by-side (keep sizes unchanged) ---
	await get_tree().process_frame # ensure ui_window is created first

	var main_window := get_window()
	var main_pos := main_window.position
	var main_size := main_window.size
	var screen_rect := DisplayServer.screen_get_usable_rect(main_window.current_screen)
	var screen_w := screen_rect.size.x

	# Try to place UI window to the right of the main one
	var desired_ui_x := main_pos.x + main_size.x + 10 # small 10px gap
	var desired_ui_y := main_pos.y

	# If it would go off-screen, move it to the left instead
	if desired_ui_x + ui_window.size.x > screen_w:
		desired_ui_x = max(0, main_pos.x - ui_window.size.x - 10)

	ui_window.position = Vector2(desired_ui_x, desired_ui_y)
	ui_window.always_on_top = true
	ui_window.exclusive = false
	ui_window.title = "Game UI"
	ui_window.show()


# --- Tile click handler ---
func _on_tile_pressed(x: int, y: int) -> void:
	var square_name = "%d-%d" % [x, y]
	var node = get_node_or_null(square_name)
	emit_signal("SendLocation", square_name)

	var pieces = get_pieces_in_square(node)
	if pieces.size() > 0:
		print("clicked square %d-%d contains pieces: %s" % [x, y, ", ".join(pieces.map(func(p): return p.name))])
		for piece in pieces:
			if piece.has_method("OnClick"):
				piece.OnClick()
	else:
		print("clicked square %d-%d (empty)" % [x, y])
		ClearSelection()

# --- Spawn pieces in starting positions ---
func RegularGameOffset() -> void:
	var OffsetOriginX = BoardXSize / 2
	var OffsetOriginY = BoardYSize / 2

	var OffsetFaction0X = OffsetOriginX - 3
	var OffsetFaction0Y = OffsetOriginY - 3
	var OffsetFaction1X = OffsetOriginX - 3
	var OffsetFaction1Y = OffsetOriginY + 3

	var F0Row1 = ["Pawn","Knight","Bishop","Queen","King","Bishop","Knight","Rook"]
	var F0Row2 = ["Pawn","Knight","Bishop","Queen","King","Bishop","Knight","Rook"]
	var F1Row1 = ["Pawn","Knight","Bishop","Queen","King","Bishop","Knight","Rook"]
	var F1Row2 = ["Pawn","Knight","Bishop","Queen","King","Bishop","Knight","Rook"]

	# Faction0 bottom
	for x in range(F0Row1.size()):
		var node_name = "%d-%d" % [OffsetFaction0X + x, OffsetFaction0Y + 1]
		var node = get_node_or_null(node_name)
		if node != null and not has_piece(node):
			SpawnPieceAtSquare(F0Row1[x], node, Faction0)
	for x in range(F0Row2.size()):
		var node_name = "%d-%d" % [OffsetFaction0X + x, OffsetFaction0Y]
		var node = get_node_or_null(node_name)
		if node != null and not has_piece(node):
			SpawnPieceAtSquare(F0Row2[x], node, Faction0)

	# Faction1 top
	for x in range(F1Row1.size()):
		var node_name = "%d-%d" % [OffsetFaction1X + x, OffsetFaction1Y]
		var node = get_node_or_null(node_name)
		if node != null and not has_piece(node):
			SpawnPieceAtSquare(F1Row1[x], node, Faction1)
	for x in range(F1Row2.size()):
		var node_name = "%d-%d" % [OffsetFaction1X + x, OffsetFaction1Y + 1]
		var node = get_node_or_null(node_name)
		if node != null and not has_piece(node):
			SpawnPieceAtSquare(F1Row2[x], node, Faction1)
