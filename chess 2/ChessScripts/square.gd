extends Button

@export var coord_x: int
@export var coord_y: int
@export var base_color: Color = Color(1,1,1)
@onready var highlight = $Highlight

func _ready():
	self.flat = true
	self.self_modulate = base_color
	highlight.color = Color(1,1,1,0)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text = "" # no label

func Highlight(color: Color, duration: float = 0.25):
	var tween = get_tree().create_tween()
	tween.tween_property(highlight, "color", Color(color.r, color.g, color.b, 1), duration)

func ClearHighlight(duration: float = 0.2):
	var tween = get_tree().create_tween()
	tween.tween_property(highlight, "color:a", 0, duration)
