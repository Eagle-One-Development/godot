extends Node2D

@onready var label: Label = $Label  # Make sure a Label node exists under Defense

# Optional colors, can be set by Piece.gd if you want
var color_primary
var color_secondary

# Internal storage for defense value
var _defense: int = 0

# Called by Piece.gd to update the defense value
func set_defense(value: int) -> void:
	_defense = clamp(value, 0, 3)  # 0:none, 1:triangle, 2:square, 3:pentagon
	_update()

# Updates the Label based on current defense value
func _update() -> void:
	if not is_instance_valid(label):
		return

	if _defense <= 0:
		label.text = ""  # hide if zero
	else:
		label.text = "Def = %d" % _defense
