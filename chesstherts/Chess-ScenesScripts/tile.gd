# T I L E #
# T I L E #
# T I L E #

# THE FKIN GOAT
# LETS CODE THE FUCKING TILES YES GOD FUCK YES
# HOW DOPE IT IS THAT TILES ARE SO SMART?

# T I L E #
extends Node2D

@onready var background: Sprite2D = $Background
@onready var button: Button = $Button
@onready var skirmish: Node = null
@onready var occupant: Node = null

@export var piece_scene: PackedScene

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
		#if skirmish:
			#if value == false:
				#skirmish.all_tiles.remove_at(self)
			#else:
				#skirmish.all_tiles.append(self)
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
	self.name = "tile_%d_%d" % [x, y]
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
	print("Tile clicked (", grid_x, "_", grid_y, ") and assign_dark = " ,assign_dark,)
	background.modulate = Color(1, 0.2, 0.2)
	print(self.global_position)
	if occupant:
		if occupant.has_method("OnClick"):
			occupant.OnClick()  # call the piece's OnClick
		else:
			push_warning("Occupant has no OnClick method!")
	else:
		print("No occupant on this tile")
	var pawn = "King"
	var black = "Black"
	spawn_piece(skirmish.piece_scene, pawn, black)
	#background.visible = true
	#playable = false
	#skirmish._Randomize_Delete_Tiles()
	#spawnpiece()
	
	
func spawn_piece(piece_scene: PackedScene, piece_type: String, faction: String):
	if occupant:
		push_warning("Tile already has a piece! " + str(name))
		return

	# 1. Instantiate piece
	var piece_instance = piece_scene.instantiate()

	# 2. Add piece to the skirmish (not as tile child)
	skirmish.add_child(piece_instance)

	# 3. Place piece at tile’s global position
	piece_instance.global_position = global_position

	# 4. Reference linking
	piece_instance._parent_tile = self
	piece_instance.skirmish = skirmish
	occupant = piece_instance

	# 5. Bootstrap / setup
	piece_instance.bootstrap(piece_type, name, faction)

	# 6. Debug info
	print("Spawned piece ", piece_type, " for faction ", faction,
		" on tile ", name,
		" piece_global: ", piece_instance.global_position)
