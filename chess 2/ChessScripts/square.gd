extends Control

@export var DefaultColor: Color
@export var HighlightColor: Color = Color(0,1,0,0.5)
var IsLightSquare: bool

@onready var background = $Background
@onready var highlight = $Highlight

func _ready():
	background.color = DefaultColor
	highlight.visible = false

func ShowHighlight():
	highlight.visible = true

func HideHighlight():
	highlight.visible = false
