# S K I R M I S H = a chessboard and UI combo, a full gameplay experience
extends Window

@onready var board_container = $HBoxContainer/BoardContainer
@onready var ui_container = $HBoxContainer/GameplayUIContainer

func _ready():
	# Set window size
	size = Vector2(1200, 800)
	always_on_top = true
	exclusive = false
	title = "Skirmish"

	# Instance the board scene
	var board_scene := load("res://board.tscn")
	var board_instance = board_scene.instantiate()
	board_container.add_child(board_instance)
	# Set board container size to match board
	board_container.size = Vector2(board_instance.get_minimum_size())

	# Instance the UI scene
	var ui_scene := load("res://gameplayui.tscn")
	var ui_instance = ui_scene.instantiate()
	ui_container.add_child(ui_instance)
	ui_instance.Init(board_instance)

	# Optional: fix UI width
	ui_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ui_container.size = ui_instance.size
