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

var _xy: Vector2i = Vector2i(0, 0)
var xy_log: Array = []

var xy: Vector2i:
	get:
		return _xy
	set(value):
		_xy = value
		if not xy_log.has(value):
			xy_log.append(value)

var push_pawn_vector: Vector2i = Vector2i(0, 0) #Vector2i(0, +-1)
# ^^^ given by its spawn info
# vector for faction1 = (0,-1) 
# vector for faction2 = (0,1) 

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
var traversal_instructions = []


var can_attack_tiles = []   # points to tiles: contains tile.occupant.faction != self.faction
var can_defend_tiles = []   # points to tiles: contains tile.occupant.faction == self.faction
var can_traverse_tiles = [] # points to tiles: contains no tile.occupant
# all of these 3 send self reference to tile.can_be_reached_by = []


var is_blocking_sliders = [] # holds ref to pieces that can move to this square	
# if self moves, these pieces get an update to their relations

func _add_blocking_reference(piece: Node):
	if is_blocking_sliders.has(piece):
		print(self.name, " failed to add block reference = ", piece.name, " because already added")
	else:
		is_blocking_sliders.append(piece)
		print(self.name, " added block reference = ", piece.name)

# CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE # CHILD KNOWLEDGE #
# SIGNALS
signal playable_changed(new_value: bool)


func UpdateMobility(piece_input: String):
	print("Updating %s with %s mobility" % [self, piece_input])


func OnClick():
	print(self.name, " PIECE BLOCKING= ", is_blocking_sliders.map(func(p): return p.name))
	print("pawn push vector = ", push_pawn_vector)
	print("piece xylog: ", xy_log)
	print("piece can attack tiles: ", can_attack_tiles.map(func(p): return p.name))
	print("piece can defend tiles: ", can_defend_tiles.map(func(p): return p.name))
	print("piece can traverse tiles: ", can_traverse_tiles.map(func(p): return p.name))
	#print(self, "defense = ", defense)
	if faction == "Skins":
		print("skin color = ", $SpriteMain.modulate)
	#print("OnClick: ", faction, playable, occupying)
	#print("piece attacking",can_attack_tiles)
	#print("piece defending",can_defend_tiles)
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
	#self.global_scale = Vector2i(1.2, 1.2)
	_highlight_active = true
	calculate_relations()
	highlight_my_reach()


				#var reachable_tiles = get_reachable_tiles()
				#if not reachable_tiles:
					#print("%s found no reachable tiles" % name)
					## if no reachable tiles, flicker self tile
					#self.occupying._flash_highlight(self.faction)
					#tile_manager.highlighted_tiles = [self.occupying]
					#return


func deselected() -> void:
	# Stop any ongoing highlight sequence
	_highlight_active = false
	self.occupying._reset_color()


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
	traversal_instructions.clear()
	attack_instructions.clear()
	#print("now adding move instructions")
	match piece_type:
		"Queen":
			# 4 diagonal sliding + 4 axis sliding
			traversal_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,-1), "max_range": 7, "type": "sliding"}
			]
			attack_instructions += [
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
			traversal_instructions += [
				{"direction": Vector2i(2,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-2,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-2,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,-2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,-2), "max_range": 1, "type": "step"},
				{"direction": Vector2i(2,-1), "max_range": 1, "type": "step"}
			]
			attack_instructions += [
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
			traversal_instructions += [
				{"direction": push_pawn_vector, "max_range": 1, "type": "step"},
			]
			attack_instructions += [
				{"direction": (push_pawn_vector + Vector2i(1, 0)), "max_range": 1, "type": "step"},
				{"direction": (push_pawn_vector + Vector2i(-1, 0)), "max_range": 1, "type": "step"},
			]
		"Rook":
			traversal_instructions += [
				{"direction": Vector2i(1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,-1), "max_range": 7, "type": "sliding"}
			]
			attack_instructions += [
				{"direction": Vector2i(1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,0), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(0,-1), "max_range": 7, "type": "sliding"}
			]
		"King":
			traversal_instructions += [
				{"direction": Vector2i(1,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,-1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(1,0), "max_range": 1, "type": "step"},
				{"direction": Vector2i(-1,0), "max_range": 1, "type": "step"},
				{"direction": Vector2i(0,1), "max_range": 1, "type": "step"},
				{"direction": Vector2i(0,-1), "max_range": 1, "type": "step"}
			]
			attack_instructions += [
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
			traversal_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"}
			]
			attack_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"}
			]
		"BigBoy":
			traversal_instructions += [
				{"direction": Vector2i(1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(1,-1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,1), "max_range": 7, "type": "sliding"},
				{"direction": Vector2i(-1,-1), "max_range": 7, "type": "sliding"}
			]
	#calculate_relations() happens in skirmish setup after all pieces spawned


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

# future design will be 
# func reposition: decides which is happening.... #
# if occupant?
	# func defend (if attack_instructions.occupant.faction == self.faction)
	# func attack (else attack_instructions.occupant.faction != self.faction)
# else
	# func move (traversal_instructions)

										#
										#func get_reachable_tiles() -> Array:
											#print("GET REACHABLE TILES CALLED.. NOT GOOD!")
											#var reachable_tiles: Array = []
										#
											#if not traversal_instructions:
												#push_warning("%s has no move instructions!" % name)
												#return reachable_tiles
										#
											#for instr in traversal_instructions:
												#var direction: Vector2i = instr.direction
												#var max_range: int = instr.max_range
												#var move_type: String = instr.type  # "sliding" or "step"
										#
												#if move_type == "step":
													#var target_xy = xy + direction
													#var target_tile = tile_manager.get_tile(target_xy.x, target_xy.y)
													#if target_tile and (not target_tile.occupant or target_tile.occupant.faction != faction):
														#reachable_tiles.append(target_tile)
										#
												#elif move_type == "sliding":
													#for i in range(1, max_range + 1):
														#var target_xy = xy + direction * i
														#var target_tile = tile_manager.get_tile(target_xy.x, target_xy.y)
														#if not target_tile or target_tile.playable == false:
															#break
														#if target_tile.occupant:
															#if target_tile.occupant.faction != faction:
																#reachable_tiles.append(target_tile)
															#break
														#reachable_tiles.append(target_tile)
											#return reachable_tiles
										#
										#func _sort_by_distance(a, b):
											#return int(b.distance - a.distance)  # closest first


# M O V E 
# M O V E 
# M O V E 
# M O V E 

func move(target_xy):
	#print("MOVE REQUEST: ", self, " to ", target_xy)
	depart_tile_occupation()
	# --- MOVE ANIMATION INSERTED HERE ---
	var target_pos: Vector2 = target_xy.position
	await animate_move(target_pos)
	# ------------------------------------
	arrive_tile_occupation(target_xy)
	update_relations_of_previously_blocked_sliders()
	calculate_relations()
	
func animate_move(target_pos: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func depart_tile_occupation():
	#clear old information
	occupying.occupant = null
	occupying = null
	update_relations_of_previously_blocked_sliders()
	clear_relations_to_tiles()
	#is_blocking_sliders.clear() # redundant?
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
	#tile_manager.highlighted_tiles = get_reachable_tiles()
	clear_relations_to_tiles()
	calculate_relations() # populate can_attack_tiles can_traverse_tiles can_defend_tiles
	
	update_relations_of_previously_blocked_sliders()
	is_blocking_sliders.clear()
	if _highlight_active == true:
		highlight_my_reach()
	#print()
	# update relations of previously blocked sliders


func _is_captured():
	print("oh no ", self, " got captured!")
	occupying = null
	playable = false
	clear_relations_to_tiles()
	#send to graveyard! from var playable!

func clear_relations_to_tiles(): 
	# 
	# tells tiles to delete references of self
	if can_traverse_tiles:
		for tile in can_traverse_tiles:
			tile.can_be_reached_by.erase(self)
	if can_attack_tiles:
		for tile in can_attack_tiles:
			tile.can_be_reached_by.erase(self)
	if can_defend_tiles:
		for tile in can_defend_tiles:
			tile.can_be_reached_by.erase(self)
	# delete tiles from my own reference
	can_traverse_tiles.clear() # append tiles to tile_manager.highlighted_tiles
	can_attack_tiles.clear() # append tiles to tile_manager.highlighted_tiles
	can_defend_tiles.clear() # no append tiles, not a valid move yet
	# no relations left!
	# is_blocking_sliders needs clear?

func calculate_relations() -> void:
	clear_relations_to_tiles()
	# --- FIRST: movement-based empty-tile detection ---
	if traversal_instructions:
		for instr in traversal_instructions:
			var direction: Vector2i = instr.direction
			var max_range: int = instr.max_range
			var move_type: String = instr.type   # "step" or "sliding"

			if move_type == "step":
				var target_tile = tile_manager.get_tile(xy.x + direction.x, xy.y + direction.y)
				if target_tile and not target_tile.occupant:
					can_traverse_tiles.append(target_tile)
					#add tile reference to self
					target_tile._add_reacher(self)
					#add self reference to tile

			elif move_type == "sliding":
				for i in range(1, max_range + 1):
					var target_tile = tile_manager.get_tile(xy.x + direction.x * i, xy.y + direction.y * i)
					if not target_tile or target_tile.playable == false:
						break
					
					if target_tile.occupant:
						#target_tile.occupant.is_blocking_sliders.append(self)
						
						break  
					can_traverse_tiles.append(target_tile)
					target_tile._add_reacher(self)
					#target_tile.can_be_reached_by.append(self)

	# --- SECOND: attack-based faction assessment ---
	if attack_instructions:
		for instr in attack_instructions:
			var direction: Vector2i = instr.direction
			var max_range: int = instr.max_range
			var attack_type: String = instr.type   # "step" or "sliding"

			if attack_type == "step":
				var target_tile = tile_manager.get_tile(xy.x + direction.x, xy.y + direction.y)
				_process_attack_tile(target_tile)

			elif attack_type == "sliding":
				for i in range(1, max_range + 1):
					var target_tile = tile_manager.get_tile(xy.x + direction.x * i, xy.y + direction.y * i)
					if not target_tile or target_tile.playable == false:
						break

					if target_tile.occupant:
						_process_attack_tile(target_tile)
						break   # sliding stops at first occupied tile


func _process_attack_tile(target_tile):
	if not target_tile:
		return
	var occ = target_tile.occupant

	if not occ:
		#even if no occupant, i could still attack that square
		target_tile._add_reacher(self)
		#can_attack_tiles.append(target_tile)
		return

	# Track relations
	if occ.faction == faction:
		can_defend_tiles.append(target_tile)
		#target_tile.can_be_reached_by.append(self)
		target_tile._add_reacher(self)
					#add self reference to tile
		target_tile.occupant._add_blocking_reference(self)
		
	else:
		can_attack_tiles.append(target_tile)
		#target_tile.can_be_reached_by.append(self)
		target_tile._add_reacher(self)
		#add self reference to tile
		target_tile.occupant._add_blocking_reference(self)

	# Tell the tile who is attacking it
	if "_is_attacked_by" in target_tile:
		target_tile.can_be_reached_by.append(self)
		

func highlight_my_reach():
	var my_reach: Array = []
	#my_reach.append(self.occupying)
	for t in can_attack_tiles:
		my_reach.append(t)
	for t in can_traverse_tiles:
		my_reach.append(t)
	tile_manager.highlighted_tiles = my_reach
	#print("highlight_my_reach: ", my_reach)

func update_relations_of_previously_blocked_sliders():
	#     "IF IM BLOCKING PIECES THEN I MOVE....we do calculate_relations"
	#used with old occupation.xy and new occupation.xy?
	for piece in is_blocking_sliders:
		piece.calculate_relations()
		print(piece, " now unblocked and calculated relations")
		is_blocking_sliders.erase(piece) # clear list
