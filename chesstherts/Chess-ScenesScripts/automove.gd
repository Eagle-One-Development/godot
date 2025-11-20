extends Node

# AutoMove.gd - Singleton-ready AI for moving pieces
# Add as Autoload singleton named "AutoMove"

# Entry point
static func piece_move(piece: Node, depth: int = 5) -> void:
	if piece == null:
		print("AutoMove: piece is null")
		return
	if piece.tile_manager == null:
		print("AutoMove: piece.tile_manager is null")
		return

	var best_tile: Node2D = _choose_best_tile(piece, depth)
	if best_tile != null:
		print(piece, " automove to ", best_tile)
		piece.move(best_tile)
	else:
		print("AutoMove: No valid moves for piece ", piece.name)


# Recursive evaluator
static func _choose_best_tile(piece: Node, depth: int) -> Node2D:
	if depth <= 0:
		return null

	var reachable_tiles: Array = piece.get_reachable_tiles()
	if reachable_tiles.size() == 0:
		return null

	var best_tile: Node2D = null
	var best_score: float = -INF
	var candidates: Array = []

	for tile in reachable_tiles:
		var score: float = _score_tile(piece, tile)

		if depth > 1:
			var simulated_piece: Piece = _clone_piece(piece)
			simulated_piece.xy = tile.xy
			score += _simulate_future_moves(simulated_piece, depth - 1)

		if score > best_score:
			best_score = score
			candidates = [tile]  # reset candidates
		elif score == best_score:
			candidates.append(tile)  # add to candidates

	if candidates.size() > 0:
		best_tile = candidates[randi() % candidates.size()]
	else:
		best_tile = null

	return best_tile



# Score a tile
static func _score_tile(piece: Node, tile: Node2D) -> int:
	var score: int = 0
	if tile.occupant != null and tile.occupant.faction != piece.faction:
		score += 10
	return score


# Recursively simulate future moves
static func _simulate_future_moves(sim_piece: Piece, depth: int) -> int:
	if depth <= 0:
		return 0

	var tiles: Array = sim_piece.get_reachable_tiles()
	if tiles.size() == 0:
		return 0

	var max_score: float = -INF
	for tile in tiles:
		var score: int = _score_tile(sim_piece, tile)
		if depth > 1:
			var next_sim: Piece = _clone_piece(sim_piece)
			next_sim.xy = tile.xy
			score += _simulate_future_moves(next_sim, depth - 1)
		if score > max_score:
			max_score = score

	return max_score if max_score != -INF else 0


# Lightweight clone of a Piece for simulation
static func _clone_piece(piece: Node) -> Piece:
	var p := Piece.new()
	p.faction = piece.faction
	p.piece_type = piece.piece_type
	p.xy = piece.xy
	p.move_instructions = piece.move_instructions.duplicate(true)
	p.tile_manager = piece.tile_manager
	return p
