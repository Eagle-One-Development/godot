extends Node

# ===================================================
# PUBLIC: Move a single piece
# ===================================================
static func piece_move(piece) -> void:
	if piece == null:
		print("AutoMove: piece is null")
		return
	if piece.tile_manager == null:
		print("AutoMove: tile_manager is null")
		return

	# Make sure relations are fresh
	piece.calculate_relations()

	var moves := []
	moves.append_array(piece.can_traverse_tiles)
	moves.append_array(piece.can_attack_tiles)

	if moves.is_empty():
		print("AutoMove: No moves for", piece.name)
		return

	var best_tile := _choose_best_tile(piece, moves)

	if best_tile:
		print("AutoMove: moving", piece.name, "to", best_tile.xy)
		piece.move(best_tile)
	else:
		print("AutoMove: No legal tile for", piece.name)



static func _choose_best_tile(piece, tiles: Array) -> Node2D:
	# where scores get counted!
	if tiles.is_empty():
		return null

	var best_score: int = -999999
	var best_tiles: Array = []

	for tile in tiles:
		if tile == null:
			continue
		var s: int = _score_tile(piece, tile)

		if s > best_score:
			best_score = s
			best_tiles = [tile]
		elif s == best_score:
			best_tiles.append(tile)

	if best_tiles.is_empty():
		return null

	# Random selection among equally scored tiles
	var chosen_tile: Node2D = best_tiles[randi() % best_tiles.size()]
	print("_choose_best_tile = ", piece, " * ", chosen_tile, " score=", best_score)
	return chosen_tile




static func _score_tile(piece, tile: Node2D) -> int:
	var score: float = 0

	# 1. CAPTURE
	if tile.occupant == null:
		score += 0
	else:
		if tile.occupant.faction != piece.faction:
			score += 10
		else:
			return -99999

	# 2. THREAT ASSESSMENT
	if tile.has_method("_assess_threat"):
		var threat_faction: String = tile._assess_threat()
		print("assess threat for ", tile.xy, " = ", threat_faction)

		if threat_faction == piece.faction:
			score += 2.2
		elif threat_faction == null:
			score += 0
		else:
			score -= 2.3
	print("score b4 pawn p= ", tile.xy, " = ", score)
	# 3. PUSH VECTOR
	if piece.push_pawn_vector != Vector2i(0, 0):
		var delta: Vector2i = tile.xy - piece.xy
		var push: Vector2i = piece.push_pawn_vector

		var x_align: bool = false
		var y_align: bool = false

		# X alignment
		if (delta.x + push.x) < delta.x:
			x_align = true

		if (delta.y + push.y) < delta.y:
			y_align = true

		# Apply bonus/penalty
		if x_align and y_align:
			score += 0
		elif x_align or y_align:
			score += 2
		else:
			score -= 0
	print("score w/ ppush = ", tile.xy, " = ", score)
	# 4. Discourage revisiting previous positions
	if piece.xy_log.has(tile.xy):
		score += -6.66
	print("score w/ xylog final = ", tile.xy, " = ", score)
	return score



static func _break_tie_by_push(piece, tiles: Array) -> Node2D:
	var push: Vector2i = piece.push_pawn_vector

	if push == Vector2i(0, 0):
		tiles.sort_custom(func(a, b): return a.xy.hash() < b.xy.hash())
		return tiles[0]

	var best: Node2D = tiles[0]
	var best_align: int = -999999

	for t in tiles:
		var delta: Vector2i = t.xy - piece.xy
		var align: int = delta.x * push.x + delta.y * push.y

		if align > best_align:
			best_align = align
			best = t

	return best



static func faction_move(faction:String) -> void:
	if faction == null:
		print("AutoMove: faction is null")
		return

	var faction_pieces := FactionManager.get_playable_pieces_by_faction(faction)

	for p in faction_pieces:
		if p:
			piece_move(p)

static func faction_move_random_one(faction: String) -> void:
	if faction == null:
		push_error("faction_move_random_one: faction is null")
		return

	# Get playable pieces
	var faction_pieces: Array = FactionManager.get_playable_pieces_by_faction(faction)
	if faction_pieces.is_empty():
		print("faction_move_random_one: no playable pieces for faction ", faction)
		return

	# Pick a random piece
	var piece: Piece = faction_pieces[randi() % faction_pieces.size()]
	if piece == null:
		return

	# Calculate piece relations
	piece.calculate_relations()

	# Combine traversable and attack tiles
	var candidate_tiles: Array = []
	candidate_tiles.append_array(piece.can_traverse_tiles)
	candidate_tiles.append_array(piece.can_attack_tiles)

	if candidate_tiles.is_empty():
		print("No valid moves for ", piece.name)
		return

	# Score all candidate tiles
	var best_score: float = -INF
	var best_tiles: Array = []

	for tile in candidate_tiles:
		if tile == null:
			continue

		var s: float = _score_tile(piece, tile)

		if s > best_score:
			best_score = s
			best_tiles = [tile]
		elif s == best_score:
			best_tiles.append(tile)

	if best_tiles.is_empty():
		print("No valid moves for ", piece.name)
		return

	# Pick a random tile among best-scoring tiles
	var chosen_tile: Node2D = best_tiles[randi() % best_tiles.size()]
	print("AutoMove moving ", piece.name, " to ", chosen_tile.xy, " (score=", best_score, ")")

	# Move the piece (updates xy property automatically)
	piece.xy = chosen_tile.xy
	piece.move(chosen_tile)
