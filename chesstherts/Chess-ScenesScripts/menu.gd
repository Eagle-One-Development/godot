extends Control

@export var tile_scene: PackedScene
@export var columns: int = 8
@export var rows: int = 8
@export var tile_size: float = 64.0
@export var faction1: String = "Black"
@export var faction2: String = "Blue"
@onready var skirmish: Node = $Skirmish

@export var piece_scene: PackedScene # this points to piece.tscn

# Each row is now an array of strings (piece names)
@export var faction1row1: Array = ["Queen", "Queen", "Queen", "Queen", "Queen", "Queen", "Queen", "Queen"]
@export var faction1row2: Array = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

@export var faction2row1: Array = ["Queen", "Queen", "Queen", "Queen", "Queen", "Queen", "Queen", "Queen"]
@export var faction2row2: Array = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

func _enter_tree():
	var skirmish: Node = $Skirmish
	skirmish.menu = self
