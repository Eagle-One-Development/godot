extends Control

@export var tile_scene: PackedScene
@export var columns: int = 8
@export var rows: int = 8
@export var tile_size: float = 64.0
@export var tile_light_color: Color = Color(0.852, 0.852, 0.852)
@export var tile_dark_color: Color = Color(0.384, 0.384, 0.384)
@export var tile_light_color2: Color = Color(0.868, 0.854, 0.863)
@export var tile_dark_color2: Color = Color(0.221, 0.221, 0.221)
@export var tile_light_color_randomization: float = 0.05
@export var tile_dark_color_randomization: float = 0.05
@export var faction1: String = "Black"
@export var faction2: String = "Blue"
@onready var skirmish: Node = $Skirmish
@onready var background: Node = $Background
var turns_type: String = "skirmish" # "strict_turns" "dynamic_turns"


@export var piece_scene: PackedScene # this points to piece.tscn

# Each row is now an array of strings (piece names)
@export var faction1row1: Array = ["Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn"]
@export var faction1row2: Array = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

@export var faction2row1: Array = ["Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn"]
@export var faction2row2: Array = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

func _enter_tree():
	var skirmish: Node = $Skirmish
	skirmish.menu = self
	if turns_type == "skirmish":
		turns_type = "skirmish"
	elif turns_type == "strict_turns":
		turns_type = "strict_turns"
	elif turns_type == "dynamic_turns":
		turns_type = "dynamic_turns"
	tile_color_to_factions()
	skirmish.turns_type = turns_type
	skirmish.tile_light_color = tile_light_color
	skirmish.tile_dark_color = tile_dark_color
	skirmish.tile_light_color2 = tile_light_color2
	skirmish.tile_dark_color2 = tile_dark_color2
	skirmish.faction1 = faction1
	skirmish.faction2 = faction2
	skirmish.tile_light_color_randomization = tile_light_color_randomization
	skirmish.tile_dark_color_randomization = tile_dark_color_randomization

func tile_color_to_factions():
	print()
	tile_light_color2 = tile_light_color.lerp(FactionManager.get_color(faction1, "primary"), 1)
	tile_dark_color2 = tile_dark_color.lerp(FactionManager.get_color(faction2, "primary"), 1)
