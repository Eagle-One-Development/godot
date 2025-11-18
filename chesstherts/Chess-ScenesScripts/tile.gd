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

var tile_light_color: Color
var tile_dark_color: Color
var tile_light_color2: Color
var tile_dark_color2: Color
var tile_light_color_randomization: float
var tile_dark_color_randomization: float
var faction1
var faction2

# SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE 
const OCTAGON_TEXTURE = preload("res://.godot/imported/octagon-64.png-969b76115dcf149304b27ac35f8b2ab5.ctex")
const SQUARE_TEXTURE = preload("res://.godot/imported/square-64.png-c3709b2dbab9a879c68e08687b46cffd.ctex")


@export var piece_scene: PackedScene # for spawning
@onready var button: Button = $Button
@onready var highlight_primary: Sprite2D = $HighlightPrimary
@onready var highlight_secondary: Sprite2D = $HighlightSecondary
@onready var background: Sprite2D = $Background
@onready var fortification_image: Sprite2D = $Fortification
var grid_x: int
var grid_y: int
var xy: Vector2i = Vector2i(0, 0)
var assign_dark: bool = false

var origin_color: Color           # only set by setup() / board pattern
var target_color: Color = Color.WHITE
var _color_tween: Tween

#@onready var highlight: Sprite2D = $Highlight
var _flashing = false  # prevent overlapping flashes

var _highlight_task: String = "" #faction here
var highlight_task: String:
	get:
		return _highlight_task
	set(value):
		_highlight_task = value
		_update_highlight_task()

#@onready var fortification_image: Sprite2D = $Fortification
var faction: String
var _fortification: int = 0
var fortification: int:
	get:
		return _fortification
	set(value):
		_fortification = clamp(value, 0, 4)  # keep in range
		#print("Faction power changed to:", _fortification)
		if _fortification <= 0:
			#print("Faction power depleted! Clearing faction.")
			fortification_image.modulate = Color(0, 0, 0, 0)  # fully transparent
			fortification_image.visible = false
			faction = ""
		else:
			# Get the base color for the faction
			var base_color: Color = FactionManager.get_color(faction, "primary") if faction else Color.WHITE

			fortification_image.visible = true
			# Scale alpha based on faction power
			var alpha: float = _fortification / 6.0  # 1→0.25, 2→0.5, 3→0.75, 4→1.0
			fortification_image.modulate = Color(base_color.r, base_color.g, base_color.b, alpha)
		if _fortification >= 4:
			var base_color: Color = FactionManager.get_color(faction, "primary") if faction else Color.WHITE
			fortification_image.modulate = Color(base_color.r, base_color.g, base_color.b, 1)
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
				background.texture =  OCTAGON_TEXTURE # SQUARE_TEXTURE  #
		if highlight_primary:
			if value == false:
				highlight_primary.texture = null
				highlight_secondary.texture = null
			else:
				highlight_primary.texture = OCTAGON_TEXTURE
				highlight_secondary.texture = OCTAGON_TEXTURE
		if fortification_image:
			if value == false:
				fortification_image.texture = null
			else:
				fortification_image.texture = OCTAGON_TEXTURE
		if occupant:
			if value == false:
				occupant.playable = false
			else:
				occupant.playable = true
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
	assign_dark = ((xy.x + xy.y) % 2 == 1)
	_highlight_ramp_to_faction_color(faction) # sets highlight to opaque black
	_set_board_color_pattern()
	update_color()
	if has_node("Fortification"):
		var fortification_image: Node2D = $Fortification
	highlight_task = ""

func _set_board_color_pattern() -> void:
	# begin with the basic tile_dark_color and tile_light_color from menu.gd
	#need an intensity variable per faction per light/dark, and call it from factionmanager?
	if assign_dark:
		background.modulate = tile_dark_color
		origin_color = tile_dark_color
	else:
		background.modulate = tile_light_color
		origin_color = tile_light_color

	# --- Apply random variance to origin_color ---
	var randomization_strength = tile_dark_color_randomization if assign_dark else tile_light_color_randomization
	if randomization_strength > 0.0:
		var rand_t = randf_range(0.0, randomization_strength)  # 0.0 → base color, 1.0 → full toward color2
		#using ..._color2, which is a faction_color lerped from ..._color(1)
		#variance is within range of ..._color and ..._color2
		if assign_dark:
			origin_color = tile_dark_color.lerp(tile_dark_color2, rand_t)
		else:
			origin_color = tile_light_color.lerp(tile_light_color2, rand_t)

	## --- Apply vertical gradient based on tile Y position ---
	#if tile_manager and tile_manager.rows > 1:
		#var row_factor: float = float(xy.y) / float(tile_manager.rows + 1)  # 0.0 top -> 1.0 bottom
#
		## strength: 0 => no effect, 1 => gentle blend, >1 => progressively sharper center
		#var strength: float = 6#3.0  # tweak this (export if you want editor slider)
		#if strength <= 0.0:
			## no gradient influence, keep origin_color as-is
			#background.modulate = origin_color
		#else:
			## make sure strength isn't zero for pow/div
			#var s: float = max(0.0001, strength)
#
			## distance from midpoint (0..0.5)
			#var dist_from_mid: float = abs(row_factor - 0.5)
#
			## normalized 0..1 where 0 = center, 1 = edge
			#var normalized: float = clamp(dist_from_mid * 2.0, 0.0, 1.0)
#
			## shape the curve: smaller exponent => softer; larger exponent => steeper near center
			## Using 1.0 / s achieves the desired behavior: s=1 -> linear, s>1 -> sharper
			#var shaped: float = pow(normalized, 1.0 / s)
#
			## convert shaped back into a 0..1 blend factor where 0=center, 1=edge, then remap to 0..1 top->bottom
			#var midpoint_curve: float = 0.5 + (shaped * 0.5 if row_factor > 0.5 else -shaped * 0.5)
#
			## Colors at extremes
			#var top_color: Color = FactionManager.get_color(faction1, "primary")
			#var bottom_color: Color = FactionManager.get_color(faction2, "primary")
#
			## gradient_color biased by midpoint_curve
			#var gradient_color: Color = top_color.lerp(bottom_color, midpoint_curve)
#
			## how strongly gradient overrides the base randomized color (0..1)
			#var influence_strength: float = clamp(s / 10.0, 0.0, 1.0)  # tweak or export as needed
#
			#origin_color = origin_color.lerp(gradient_color, influence_strength)
			#background.modulate = origin_color








func _highlight_ramp_to_faction_color(faction_to_highlight: String) -> void:
	if not highlight_primary:
		return
	if faction_to_highlight == "Reset":
		var target_color_primary = FactionManager.get_color(faction_to_highlight, "primary")
		var target_color_secondary = FactionManager.get_color(faction_to_highlight, "secondary")
		print()

	var target_color_primary = FactionManager.get_color(faction_to_highlight, "primary")
	var target_color_secondary = FactionManager.get_color(faction_to_highlight, "secondary")

	var current_color_primary: Color = highlight_primary.modulate
	var current_color_secondary: Color = highlight_secondary.modulate
	
	# If the color is already close enough, skip tween
	if current_color_primary.is_equal_approx(target_color_primary):
		return

	# Stop any previous tween cleanly
	if _color_tween and _color_tween.is_running():
		_color_tween.kill()

	_color_tween = create_tween()
	var 	duration = 0.4
	# Tween from *current visible color* to the new color
	_color_tween.tween_property(highlight_primary, "modulate", target_color_primary, duration)
	_color_tween.tween_property(highlight_secondary, "modulate", target_color_secondary, duration)

func update_color() -> void:
	if highlight_primary:
		highlight_primary.modulate = color
		

func _reset_color(duration: float = 0) -> void:
	highlight_task = ""
	if origin_color:
		_highlight_ramp_to_faction_color("Reset")


func _on_click():
	#print(self," ", tile_light_color, " ", tile_dark_color, )

	emit_signal("clicked_tile", self)
	#print("occupant = ", occupant)
	var pawn = "King"
	var black = "Black"
	#spawn_piece(pawn, black)
	#background.visible = true
	#playable = false
	#skirmish._Randomize_Delete_Tiles()
	#spawnpiece()
	#print(name, " with faction ", faction, " and power of ", fortification, )
	
	
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
		
func _update_highlight_task():
	# Cleanly kill old tween if needed
	if _color_tween and _color_tween.is_running():
		_color_tween.kill()

	_color_tween = create_tween()
	var duration := 0.2

	# FADE OUT CASE: highlight_task == ""
	if _highlight_task == "":
		# Fade alpha → 0
		_color_tween.parallel().tween_property(
			highlight_primary, "modulate:a", 0.0, duration
		)
		_color_tween.parallel().tween_property(
			highlight_secondary, "modulate:a", 0.0, duration
		)

		# After fade-out, hide them
		_color_tween.finished.connect(func():
			highlight_primary.visible = false
			highlight_secondary.visible = false
		)
		return
	# FADE IN TO FACTION COLOR CASE
	highlight_primary.visible = true
	highlight_secondary.visible = true

	var target_color_primary   = FactionManager.get_color(_highlight_task, "primary")
	var target_color_secondary = FactionManager.get_color(_highlight_task, "secondary")

	# Ensure colors are fully opaque before tweening
	target_color_primary.a = 1
	target_color_secondary.a = 1
	#if assign_dark:
		#target_color_primary = Color.WHITE
		#target_color_secondary = Color.WHITE

	# Tween both modulates toward the faction colors
	_color_tween.parallel().tween_property(
		highlight_primary, "modulate", target_color_primary, duration
	)

	_color_tween.parallel().tween_property(
		highlight_secondary, "modulate", target_color_secondary, duration
	)


func _flash_highlight(faction: String) -> void:
	_flashing = true
	var flicker_times := 100
	var wait_time := 0.4  # seconds per flicker

	for i in range(flicker_times):
		if _flashing == false:
			_reset_color(0.2)
			break
		_reset_color(0.2)
		await get_tree().create_timer(wait_time).timeout
		
		var base_color := FactionManager.get_color(faction, "primary")
		var highlight_color := base_color * 0.7 if assign_dark else base_color
		_highlight_ramp_to_faction_color(faction)
		
		await get_tree().create_timer(wait_time).timeout
	
	_flashing = false
	

func _fortify(occupant_faction):
	if fortification == 0:
		faction = occupant_faction
		fortification = 1
	if occupant_faction == faction:
		fortification += 1
	else:
		fortification += -1
	if fortification == 0:
		self.faction = occupant_faction
		fortification = 1
	#print()
	

func ramp_origin_color():
	print()
