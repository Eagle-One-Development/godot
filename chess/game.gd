extends Node2D
# This is the main game scene script.

@onready var board_generator: Node2D = get_node("Generator")
var pos: Vector2

func _ready() -> void:
	pos = Vector2(
		board_generator.TileXSize / 2,
		board_generator.TileYSize / 2
	)
	board_generator.generate_board()  # Tell generator to make the checkerboard
