class_name Piece
extends Node2D  # or whatever base you use


# guidelines
# never parented to tile? only parented to skirmish

# PARENT KNOWLEDGE # PARENT KNOWLEDGE # PARENT KNOWLEDGE 
var skirmish = null
var tile_manager
var occupying: Node = null # tile scene obj
# SELF KNOWLEDGE # SELF KNOWLEDGE # SELF KNOWLEDGE 
var faction: String = "Skin"
var piece_type: String = "Pawn"
var PieceTextures: Dictionary = {}

var xy: Vector2i = Vector2i(0, 0)

var color_primary
var color_secondary

@onready var defense_layer: Node2D = $Defense

# Internal storage for defense
# Internal storage + property with get/set
var _defense: int = 1
var defense: int:
	get:
		return _defense
	set(value):
		_defense = clamp(value, 0, 3)  # 0: none, 1: triangle, 2: square, 3: pentagon
		#print("Defense changed to:", _defense)

		# Update the Defense layer if it exists
		if is_instance_valid(defense_layer):
			defense_layer.set_defense(_defense)
			defense_layer.color_primary = color_primary
			defense_layer.color_secondary = color_secondary
			#defense_layer.update()


var _highlight_active: bool = false
var _playable: bool = true
var playable: bool:
	#FactionManager.register_piece_playable(self)
	get:
		return _playable
	set(value):
		if _playable == value:
			return #disregard duplicate value
		_playable = value #non duplicate is assigned
		emit_signal("playable_changed", value)
		if not value:
			visible = false
			FactionManager.register_piece_nonplayable(self)
			skirmish.skirmishui._piece_to_graveyard(self)
		else:
			visible = true
			FactionManager.register_piece_playable(self)


var defend_instructions = []  # defend = attack on a piece that just captured
var attack_instructions = []
var move_instructions = []

# CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE #
var _is_attacked_by = []
var _is_defended_by = []
# SIGNALS
signal playable_changed(new_value: bool)


func UpdateMobility(piece_input: String):
	print("Updating %s with %s mobility" % [self, piece_input])


func OnClick():
	print(self, "defense = ", defense)
	if faction == "Skins":
		print("skin color = ", $SpriteMain.modulate)
	print("OnClick: ", faction, playable, occupying)
	#print("OnClick: ", piece_type)
	#print("OnClick: ", self.global_position)
	#print("OnClick: PARENT ", parent_tile)
	#print("OnClick: MoveDeltaXY = " + str(MoveDeltaXY))
	#print(name, " is at location ", xy)
	#print("onclick highlight active", _highlight_active)
	#print("OnClick: SKIRMISH = ", skirmish)
	#print("OnClick: TILEMANAGER = ", tile_manager)
	#HighlightMoves()
	tile_manager.SelectedPiece = self


func selected() -> void:
	# Start highlight sequence
	_highlight_active = true
	tile_manager.highlighted_tiles = get_reachable_tiles()

	var reachable_tiles = get_reachable_tiles()
	if not reachable_tiles:
		print("%s found no reachable tiles" % name)
		# if no reachable tiles, flicker self tile
		self.occupying._flash_highlight(self.faction)
		tile_manager.highlighted_tiles = [self.occupying]
		return

#
	## highlight animation
	## Group tiles by distance
	#var waves := {}
	#for item in reachable_tiles:
		#var dist = item.distance
		#if not waves.has(dist):
			#waves[dist] = []
		#waves[dist].append(item.tile)
#
	#var sorted_distances = waves.keys()
	#sorted_distances.sort()  # closest first
	## Timing
	#var total_time: float = 0.01
	#var first_delay: float = 0.01
	#var remaining_time: float = total_time - first_delay
	#var num_waves: int = sorted_distances.size()
	#var per_wave_delay: float = 0
	#if num_waves > 1:
		#per_wave_delay = remaining_time / (num_waves - 1)
#
	## Highlight each wave
	#for i in range(num_waves):
		## Wait for delay
		#await get_tree().create_timer(first_delay + per_wave_delay * i).timeout
#
		## Stop if deselected
		#if not _highlight_active:
			#return
#
		#for tile in waves[sorted_distances[i]]:
			#tile._highlight_for_faction(faction)
	##print("tile_manager.highlighted_tiles = ", tile_manager.highlighted_tiles)


func deselected() -> void:
	# Stop any ongoing highlight sequence
	_highlight_active = false
	self.occupying._reset_color()

	## Reset highlighted tiles
	#var reachable_tiles = get_reachable_tiles()
	#for item in reachable_tiles:
		#item.tile._reset_color()
		#item.tile._flashing = false


func get_reachable_tiles() -> Array:
	var reachable_tiles: Array = []

	if not move_instructions:
		push_warning("%s has no move instructions!" % name)
		return reachable_tiles

	for instr in move_instructions:
		var direction: Vector2i = instr.direction
		var max_range: int = instr.max_range
		var move_type: String = instr.type  # "sliding" or "step"

		if move_type == "step":
			var target_xy = xy + direction
			var target_tile = tile_manager.get_tile(target_xy.x, target_xy.y)
			if target_tile and (not target_tile.occupant or target_tile.occupant.faction != faction):
				reachable_tiles.append(target_tile)

		elif move_type == "sliding":
			for i in range(1, max_range + 1):
				var target_xy = xy + direction * i
				var target_tile = tile_manager.get_tile(target_xy.x, target_xy.y)
				if not target_tile or target_tile.playable == false:
					break
				if target_tile.occupant:
					if target_tile.occupant.faction != faction:
						reachable_tiles.append(target_tile)
					break
				reachable_tiles.append(target_tile)
	return reachable_tiles

func _sort_by_distance(a, b):
	return int(b.distance - a.distance)  # closest first


func bootstrap(piece_input: String, tile_input: Vector2i, faction_input: String):
	load_assets()
	#print("Bootstrapping %s for %s at %s" % [piece_input, faction_input, tile_input])
	#
	## --- Populate instance variables ---
	self.name = faction_input + piece_input
	self.faction = faction_input
	self.piece_type = piece_input
	self.xy = tile_input
	FactionManager.register_piece_playable(self)
	if piece_input == "Queen":
		defense = 3
	occupying._fortify(faction)
	#self.global_position = parent_tile.global_position
	
	## --- Validate piece type ---
	if not PieceTextures.has(piece_input):
		#push_error("Piece Type not found: %s" % piece_input)
		return
	# --- Assign texture ---
	var piece_texture: Texture2D = PieceTextures[piece_input]
	if has_node("SpriteMain"):
		$SpriteMain.texture = piece_texture
	else:
		#push_warning("SpriteMain not found; applying texture to root node")
		self.texture = piece_texture
	#print("Bootstrap: %s texture assigned!" % piece_input)
	
	# --- Apply faction colors ---
	var color_primary := FactionManager.get_color(faction, "primary")
	if has_node("SpriteMain"):
		$SpriteMain.modulate = color_primary
		color_primary = color_primary
	else:
		self.modulate = color_primary

	if has_node("SpriteAccents"):
		var color_secondary := FactionManager.get_color(faction, "secondary")
		$SpriteAccents.modulate = color_secondary
		color_secondary = color_secondary
	else:
		print()
		#push_warning("SpriteAccents not found; secondary color skipped")

	if has_node("SpriteAccents"):
		$SpriteAccents.texture = piece_texture
	else:
		print()
	if has_node("Defense"):
		var defense_layer: Node2D = $Defense
		defense = 1
		#print("defense node found!")
		#push_warning("SpriteAccents not found; applying texture to root node")
	#print("Bootstrap: %s accent texture assigned!" % piece_input)

	# --- Assign moves based on piece type ---
	move_instructions.clear()
	#print("now adding move instructions")
	match piece_type:
		"Queen":
			# 4 diagonal sliding + 4 axis sliding
			move_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,-1), "max_range": 7, "type": "sliding"}
			]
		"Knight":
			move_instructions += [
				{"direction": Vector2i(2,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-2,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-2,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,-2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,-2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(2,-1), "max_range": 1, "type": "step"}
			]
		"Pawn":
			# Simple pawn moves (forward only, no captures yet)
			# Could later add diagonal capture instructions
			move_instructions += [
				{"direction": Vector2i(0,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(0,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,0), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,0), "max_range": 1, "type": "step"},
			]
		"Rook":
			move_instructions += [
				{"direction": Vector2i(1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,-1), "max_range": 7, "type": "sliding"}
			]
		"King":
			move_instructions += [
				{"direction": Vector2i(1,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,0), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,0), "max_range": 1, "type": "step"},
				{"direction": Vector2i(0,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(0,-1), "max_range": 1, "type": "step"}
			]
		"Bishop":
			move_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"}
			]
		"BigBoy":
			move_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"}
			]


func load_assets():
	PieceTextures = {
		"Pawn": load("res://Chess-Assets/WPawn.svg"),
		"Knight": load("res://Chess-Assets/WKnight.svg"),
		"Bishop": load("res://Chess-Assets/WBishop.svg"),
		"Rook": load("res://Chess-Assets/WRook.svg"),
		"Queen": load("res://Chess-Assets/WQueen.svg"),
		"King": load("res://Chess-Assets/WKing.svg"),
		"BigBoy": load("res://Chess-Assets/WKing.svg"),
	}


func move(target_xy):
	#print("MOVE REQUEST: ", self, " to ", target_xy)
	depart_tile_occupation()
	#insert move animation here
	arrive_tile_occupation(target_xy)
	#deselected()
	tile_manager.highlighted_tiles = get_reachable_tiles()
	

func depart_tile_occupation():
	#clear old information
	occupying.occupant = null
	occupying = null
	#tile_manager._reset_highlighted_tiles()
	#print()
	#FactionManager
	# to all pieces you are currently attacking and defending: calculate_relations()

func arrive_tile_occupation(target_xy):
	if target_xy.occupant and target_xy.occupant.faction != self.faction:
		print() # we attack!!
		target_xy.occupant._is_captured()
	# now begin ordinary move
	# populate new information
	# decision tree priority: Defend -> attack -> move
	# defend is an attack + bonuses
	# move is no attack
	xy = target_xy.xy
	target_xy.occupant = self
	occupying = target_xy
	position = target_xy.position
	occupying._fortify(faction)
	tile_manager.highlighted_tiles = get_reachable_tiles()
	calculate_relations()
	#print()


func _is_captured():
	print("oh no ", self, " got captured!")
	occupying = null
	playable = false
	#send to graveyard! from var playable!

func calculate_relations():
	print()
