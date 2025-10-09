extends Node2D
# A single square in the checkerboard.

@export var light_color: Color = Color(1, 1, 1)  # White
@export var dark_color: Color = Color(0, 0, 0)   # Black

var sprite: Sprite2D  # The visual part of the square

func _ready() -> void:
	# Find the Sprite2D inside this square
	sprite = $Sprite2D

func set_square_color(x: int, y: int) -> void:
	# Checkerboard pattern logic: sum of coordinates determines color
	if (x + y) % 2 == 0:
		sprite.modulate = light_color  # Even sum → light square
	else:
		sprite.modulate = dark_color   # Odd sum → dark square
