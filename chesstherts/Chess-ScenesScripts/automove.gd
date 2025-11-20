extends Node

# ===================================================
# PUBLIC ENTRY POINT
# ===================================================
static func piece_move(piece, depth: int = 3) -> void:
	if piece == null:
		print("AutoMove piece_move: piece is null")
		return
	if piece.tile_manager == null:
		print("AutoMove piece_move: piece.tile_manager is null")
		return

	var tile: Node2D = _choose_best_tile(piece, depth)
	if tile != null:
		print("AutoMove: moving", piece.name, "to", tile.xy)
		piece.move(tile)
	else:
		print("AutoMove: No valid move for", piece.name)

# ===================================================
# Make all moves for a faction
# ===================================================
static func faction_move(faction, depth: int = 3) -> void:
	if faction == null:
		print("AutoMove faction_move: faction is null")
		return

	# Get all playable pieces for this faction
	var faction_pieces: Array = FactionManager.get_playable_pieces_by_faction(faction)
	if faction_pieces.size() == 0:
		print("AutoMove faction_move: no playable pieces for faction", faction)
		return

	# List of pieces that can capture an enemy in 1 move
	var priority_list: Array = []

	for piece in faction_pieces:
		# Check the best move with depth = 1 (1-turn moves)
		var piece_best_tile: Node2D = _choose_best_tile(piece, 1)
		if piece_best_tile != null:
			# If best tile has enemy occupant, this is a capture opportunity
			if piece_best_tile.occupant != null and piece_best_tile.occupant.faction != faction:
				priority_list.append(piece)
				print("AutoMove faction_move: piece", piece.name, "can capture", piece_best_tile.occupant.name)

	# For now, just print priority list
	if priority_list.size() > 0:
		print()
		#print("AutoMove faction_move: priority capture pieces:", [p.name for p in priority_list])
	else:
		print("AutoMove faction_move: no immediate captures available")








# ===================================================
# PRUNING DEPTH SEARCH
# ===================================================
static func _choose_best_tile(piece, depth: int) -> Node2D:
	var seen := {}

	var frontier: Array = piece.get_reachable_tiles()
	var origin_layer: Array = frontier.duplicate()
	var layer_depth: int = depth

	# Mark initial
	for tile in frontier:
		if tile is Node2D:
			seen[tile.xy] = true

	var best_first_layer: Node2D = _best_tile_from_list(piece, origin_layer)
	var best_score: float = -INF

	# Evaluate score for depth-1 moves
	if best_first_layer != null:
		best_score = _score_tile(piece, best_first_layer)

	# Now explore future layers, but DO NOT return them directly
	while layer_depth > 1:
		var next_layer: Array = []

		for tile in frontier:
			if not (tile is Node2D):
				continue

			var tiles2: Array = _pseudo_reachable(piece, tile.xy)

			for t in tiles2:
				if t is Node2D and not seen.has(t.xy):
					seen[t.xy] = true
					next_layer.append(t)

		if next_layer.size() == 0:
			break

		# Deep layer scoring—only UPDATE score, don't select illegal tiles
		var deep_candidate: Node2D = _best_tile_from_list(piece, next_layer)
		if deep_candidate != null:
			var s = _score_tile(piece, deep_candidate)
			if s > best_score:
				best_score = s
				# DO NOT REPLACE with deep_candidate
				# Instead reinforce best_found_from_first_layer
				best_first_layer = _best_tile_from_list(piece, origin_layer)

		frontier = next_layer
		layer_depth -= 1

	return best_first_layer


# ===================================================
# SCORING
# ===================================================
static func _score_tile(piece, tile: Node2D) -> float:
	if tile.occupant == null:
		return 1.0
	elif tile.occupant.faction != piece.faction:
		return 10.0
	else:
		return -99999.0


# ===================================================
# RANDOM TIEBREAKING
# ===================================================
static func _best_tile_from_list(piece, tiles: Array) -> Node2D:
	if tiles.size() == 0:
		return null

	var best_score: float = -INF
	var candidates: Array = []

	for tile in tiles:
		if not (tile is Node2D):
			continue

		var score: float = _score_tile(piece, tile)

		if score > best_score:
			best_score = score
			candidates = [tile]
		elif score == best_score:
			candidates.append(tile)

	if candidates.size() == 0:
		return null

	return candidates[randi() % candidates.size()]


# ===================================================
# GENERATE MOVES FOR A PIECE AT *TEMPORARY XY*
# ===================================================
static func _pseudo_reachable(piece, xy: Vector2i) -> Array:
	var results: Array = []

	for instr in piece.move_instructions:
		var dir: Vector2i = instr.direction
		var rng: int = instr.max_range
		var typ: String = instr.type

		if typ == "step":
			var txy: Vector2i = xy + dir
			var tile: Node2D = piece.tile_manager.get_tile(txy.x, txy.y)
			if tile and (tile.occupant == null or tile.occupant.faction != piece.faction):
				results.append(tile)

		elif typ == "sliding":
			for i in range(1, rng + 1):
				var txy: Vector2i = xy + dir * i
				var tile: Node2D = piece.tile_manager.get_tile(txy.x, txy.y)

				if tile == null or not tile.playable:
					break

				if tile.occupant:
					if tile.occupant.faction != piece.faction:
						results.append(tile)
					break

				results.append(tile)

	return results
