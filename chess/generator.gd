extends Node2D
# This script generates the checkerboard squares.

@export var TileXSize: float = 64.0   # Width of each tile in pixels
@export var TileYSize: float = 64.0   # Height of each tile in pixels
@export var board_width: int = 8      # Number of columns
@export var board_height: int = 8     # Number of rows

@export var square_scene: PackedScene  # The square scene to instantiate

func generate_board() -> void:
	# Loop through each board row
	for y in range(board_height):
		# Loop through each board column
		for x in range(board_width):
			# Instantiate a new square from the scene
			var square: Node2D = square_scene.instantiate()
			
			# Set its position manually based on tile size
			square.position = Vector2(x * TileXSize, y * TileYSize)
			
			# Pass its grid coordinates so it knows if it’s light or dark
			square.set_square_color(x, y)
			
			# Add it to the board as a child
			add_child(square)
