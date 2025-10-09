extends Control

@export var DefaultColor: Color
@export var HighlightColor: Color = Color(0,1,0,0.5)

@onready var background = $Background
@onready var highlight = $Highlight

func _ready():
	# Ensure the background color is correct
	if background:
		background.color = DefaultColor
		background.anchor_left = 0
		background.anchor_top = 0
		background.anchor_right = 1
		background.anchor_bottom = 1
		background.size_flags_horizontal = Control.SIZE_FILL
		background.size_flags_vertical = Control.SIZE_FILL

	if highlight:
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.color = HighlightColor
		highlight.visible = false
		highlight.anchor_left = 0
		highlight.anchor_top = 0
		highlight.anchor_right = 1
		highlight.anchor_bottom = 1
		highlight.size_flags_horizontal = Control.SIZE_FILL
		highlight.size_flags_vertical = Control.SIZE_FILL

# Set the size of the tile dynamically
func SetTileSize(tile_size: Vector2):
	size = tile_size
	if background:
		background.size = tile_size
	if highlight:
		highlight.size = tile_size

func SetBaseColor(color: Color):
	DefaultColor = color
	if background:
		background.color = color

func ShowHighlight():
	if highlight:
		highlight.visible = true

func HideHighlight():
	if highlight:
		highlight.visible = false
