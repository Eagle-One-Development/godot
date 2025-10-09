extends Node2D
# piece.gd — represents a game piece

@export var piece_color: Color = Color(1, 0, 0)  # Default red piece
@export var piece_size: float = 32.0  # Diameter in pixels

func _ready() -> void:
	# Example of setting piece appearance
	var visual_node = get_node("Sprite2D")  # Adjust if using another visual
	visual_node.modulate = piece_color
	visual_node.scale = Vector2(
		piece_size / visual_node.texture.get_width(),
		piece_size / visual_node.texture.get_height()
	)
