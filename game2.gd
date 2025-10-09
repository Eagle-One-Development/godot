extends Node2D
# Square.gd — represents a single square on the board

@export var TileXSize: float = 64.0  # Width of a single square in pixels
@export var TileYSize: float = 64.0  # Height of a single square in pixels
@export var light_color: Color = Color(0.9, 0.9, 0.9)  # Color for light tiles
@export var dark_color: Color = Color(0.2, 0.2, 0.2)   # Color for dark tiles

var row: int = 0  # Board row index
var col: int = 0  # Board column index

func setup(_row: int, _col: int) -> void:
	# Called after instantiation to initialize the square's position & color
	row = _row
	col = _col

	# Position the square on the board
	position = Vector2(col * TileXSize, row * TileYSize)

	# Pick color based on sum of row + col (checkerboard pattern)
	var is_light: bool = ((row + col) % 2 == 0)
	var final_color: Color = light_color if is_light else dark_color

	# Assume the square scene has a child ColorRect or Sprite2D to set the color
	var visual_node = get_node("Sprite2D")  # Change if using ColorRect
	visual_node.modulate = final_color
