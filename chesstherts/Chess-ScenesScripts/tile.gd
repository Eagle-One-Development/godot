# TILE THE FKIN GOAT
# LETS CODE THE FUCKING TILES YES GOD FUCK YES
# HOW DOPE IT IS THAT TILES ARE SO SMART?

extends Node2D

@onready var background: Sprite2D = $Background
@onready var button: Button = $Button
const OCTAGON_TEXTURE = preload("res://.godot/imported/octagon-64.png-969b76115dcf149304b27ac35f8b2ab5.ctex")

var assign_dark: bool = false
var playable: bool = true: # to set to true, you cant use the button, use the "all_tiles" array
	set(value):
		playable = value
		if button:
			button.disabled = not value

		if background:
			if value == false:
				background.texture = null
			else:
				background.texture = load("res://.godot/imported/octagon-64.png-969b76115dcf149304b27ac35f8b2ab5.ctex")
	get:
		return playable
	
var faction: String = "null"
var factionpower: int = 0 # 0 - 100, upon reaching zero, it will set faction to null
	#set(value):
		#if factionpower == value:
			#ClearSelection()
		#else:
			#_selected_piece = value
			#emit_signal("selected_piece_changed", value)
			#print("Selected Piece: ", value)
	#get:
		#return _selected_piece

var color: Color = Color.WHITE:
	set(value):
		color = value
		update_color()

var grid_x: int
var grid_y: int

func _ready():
	button.pressed.connect(_on_click)
	update_color()

func setup(x: int, y: int):
	playable = true
	grid_x = x
	grid_y = y
	self.name = "Tile_%d_%d" % [x, y]
	print("just made ", name)

	_assign_dark_square()
	_set_board_color_pattern(x, y)
	update_color()
	


func _assign_dark_square():
	# Assign dark or light based on coordinates
	if (grid_x + grid_y) % 2 == 0:
		assign_dark = false
	else:
		assign_dark = true
		
		
func _set_board_color_pattern(x: int, y: int):
	var is_dark = (x + y) % 2 == 1
	color = Color(0.4, 0.4, 0.4) if is_dark else Color(0.85, 0.85, 0.85)

func update_color():
	background.modulate = color

func _on_click():
	print("Tile clicked (", grid_x, ", ", grid_y, ") and assign_dark = " ,assign_dark )
	background.modulate = Color(1, 0.2, 0.2)
	#background.visible = true
	playable = false
	
	#if: self.name == Tile_1_1
	#	skirmish.all_tiles()
