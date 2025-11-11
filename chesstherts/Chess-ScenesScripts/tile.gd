# T I L E #
# T I L E #
# T I L E #

# THE FKIN GOAT
# LETS CODE THE FUCKING TILES YES GOD FUCK YES
# HOW DOPE IT IS THAT TILES ARE SO SMART?
@tool
# T I L E #
extends Node2D

# PARENT KNOWLEDGE # PARENT KNOWLEDGE # PARENT KNOWLEDGE # PARENT KNOWLEDGE 
@onready var skirmish: Node = null
var turns_type: String = "skirmish"
var tile_manager

# SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE 
const OCTAGON_TEXTURE = preload("res://.godot/imported/octagon-64.png-969b76115dcf149304b27ac35f8b2ab5.ctex")
@export var piece_scene: PackedScene # for spawning
@onready var background: Sprite2D = $Background
@onready var button: Button = $Button
var grid_x: int
var grid_y: int
var xy: Vector2i = Vector2i(0, 0)
var assign_dark: bool = false
var origin_color: Color = Color.WHITE # only set on spawn = base color + randomizations "reset here"

var faction: String = "null"
var factionpower: int = 0 # 0 - 100, upon reaching zero, it will set faction to null

# CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE 
@onready var occupant: Node = null



var color: Color = Color.WHITE: # all color changes go to here
	set(value):
		color = value
		update_color()


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

signal clicked_tile(tile)

func _ready():
	button.pressed.connect(_on_click)
	update_color()
	_set_board_color_pattern()


func setup(x: int, y: int) -> void:
	playable = true
	xy = Vector2i(x, y)
	name = "tile_%d_%d" % [x, y]
	_assign_dark_square()
	_set_board_color_pattern()
	update_color()


func _assign_dark_square() -> void:
	assign_dark = ((xy.x + xy.y) % 2 == 1)

		
		
func _set_board_color_pattern() -> void:
	var is_dark = ((xy.x + xy.y) % 2 == 1)
	color = Color(0.4, 0.4, 0.4) if is_dark else Color(0.85, 0.85, 0.85)
		


func update_color() -> void:
	if background:
		background.modulate = color
		

func _reset_color() -> void:
	# Reset to base board color pattern
	_set_board_color_pattern()
	update_color()

func _on_click():
	emit_signal("clicked_tile", self)
	#print("occupant = ", occupant)
	var pawn = "King"
	var black = "Black"
	#spawn_piece(pawn, black)
	#background.visible = true
	#playable = false
	#skirmish._Randomize_Delete_Tiles()
	#spawnpiece()
	print("tile on click xy = ", xy)
	
	
func spawn_piece(piece_type: String, faction: String):
	if occupant:
		#push_warning("Tile already has a piece! " + str(name))
		return

	# 1. Instantiate piece
	var piece_instance = piece_scene.instantiate()

	# 2. Add piece to the skirmish (not as tile child)
	skirmish.add_child(piece_instance)

	# 3. Place piece at tile’s global position
	piece_instance.global_position = global_position
	#print("TILE MANAGER CHECK =", tile_manager)
	# 4. Reference linking
	#piece_instance._parent_tile = self
	piece_instance.skirmish = skirmish
	piece_instance.tile_manager = tile_manager
	piece_instance.occupying = self
	#print("tile manager reference = ", tile_manager)
	occupant = piece_instance

	# 5. Bootstrap / setup
	piece_instance.bootstrap(piece_type, xy, faction)

	# 6. Debug info
	#print("Spawned piece ", piece_type, " for faction ", faction,
		#" on tile ", name,
		#" piece_global: ", piece_instance.global_position)

var _flashing = false  # prevent overlapping flashes

func _highlight_for_faction(faction: String):
	var base_color := FactionManager.get_color(faction, "primary")
	var highlight_color := base_color * 0.7 if assign_dark else base_color

	background.modulate = highlight_color
	
	if occupant and occupant.faction != faction:
		if not _flashing:
			_flash_highlight(faction)


func _flash_highlight(faction: String) -> void:
	_flashing = true
	var flicker_times := 100
	var wait_time := 0.07  # seconds per flicker

	for i in range(flicker_times):
		if _flashing == false:
			_reset_color()
			break
		_reset_color()
		await get_tree().create_timer(wait_time).timeout
		
		var base_color := FactionManager.get_color(faction, "primary")
		var highlight_color := base_color * 0.7 if assign_dark else base_color
		background.modulate = highlight_color
		await get_tree().create_timer(wait_time).timeout
	
	_flashing = false
