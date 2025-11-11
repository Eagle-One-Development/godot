# FactionManager.gd
extends Node
#class_name FactionManager

#var all_skins_pieces: Array = []
#var all_red_pieces: Array = []
#var all_blue_pieces: Array = []
#var all_black_pieces: Array = []
#var all_white_pieces: Array = []

# Define immutable faction data
const FACTIONS := {
	"White": { # lighter primary, darker secondary
		"primary": Color(1, 1, 1, 1),
		"secondary": Color(0.7, 0.7, 0.7, 1),
		"gold": 0,
		"boots": 0
	},
	"Black": { # darker primary, lighter secondary
		"primary": Color(0.1, 0.1, 0.1, 1),
		"secondary": Color(0.5, 0.5, 0.5, 1),
		"gold": 0,
		"boots": 0
	},
	"Red": { # darker primary, lighter secondary
		"primary": Color(0.76, 0, 0, 1),
		"secondary": Color(0.5, 0.1, 0.1, 1),
		"gold": 0,
		"boots": 0
	},
	"Blue": { # lighter primary, darker secondary
		"primary": Color(0.103, 0.405, 1, 1),
		"secondary": Color(0.3, 0.5, 1, 1),
		"gold": 0,
		"boots": 0
	},
		"Skins": {
		"primary": Color(0.9, 0.7, 0.6, 1),
		"secondary": Color(0.6, 0.4, 0.3, 1),
		"gold": 0,
		"boots": 0
	},
}

# --- Lookup helper methods ---
static func get_color(faction: String, key: String = "primary") -> Color:
	if not FACTIONS.has(faction):
		push_warning("Invalid faction: " + faction)
		return Color(1, 0, 1, 1) # magenta for error
	return FACTIONS[faction].get(key, Color(1, 0, 1, 1))

static func get_stat(faction: String, stat: String) -> int:
	if not FACTIONS.has(faction):
		push_warning("Invalid faction: " + faction)
		return 0
	return FACTIONS[faction].get(stat, 0)

static func get_info(faction: String) -> Dictionary:
	return FACTIONS.get(faction, {})
