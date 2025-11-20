# FactionManager.gd
extends Node
#class_name FactionManager

static var faction_members_playable := { # pieces in play
	# used for calculating all relationships between pieces
	"White": [],
	"Black": [],
	"Red": [],
	"Blue": [],
	"Skins": [],
}
static var faction_members_nonplayable := { # pieces not in play "captured" "banished"
	"White": [],
	"Black": [],
	"Red": [],
	"Blue": [],
	"Skins": [],
}

static func register_piece_playable(piece: Node):
	print("FacMan: register ", piece, " playable")
	var faction = piece.faction

	if faction_members_playable.has(faction):
		if not faction_members_playable[faction].has(piece):
			faction_members_playable[faction].append(piece)

		# Remove from nonplayable if needed
		if faction_members_nonplayable[faction].has(piece):
			faction_members_nonplayable[faction].erase(piece)

	print("inplay for ", faction, faction_members_playable[faction])

static func register_piece_nonplayable(piece: Node):
	print("FacMan: register ", piece, " nonplayable")
	var faction = piece.faction

	if faction_members_nonplayable.has(faction):
		# ADD TO GRAVEYARD
		if not faction_members_nonplayable[faction].has(piece):
			faction_members_nonplayable[faction].append(piece)

		# REMOVE FROM playable
		if faction_members_playable[faction].has(piece):
			faction_members_playable[faction].erase(piece)

	print("GY for ", faction, faction_members_nonplayable[faction])

static func get_playable_pieces_by_faction(faction: String) -> Array:
	print("inplay for ", faction, faction_members_playable.get(faction, []))
	return faction_members_playable.get(faction, [])

static func get_nonplayable_pieces_by_faction(faction: String) -> Array:
	print("GY for ", faction, faction_members_nonplayable.get(faction, []))
	return faction_members_nonplayable.get(faction, [])


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
const SKINS_PRIMARY_OPTIONS := [ 
	#https://www.schemecolor.com/tan-on-skin-color-scheme.php
	# WHO ARE THE SKINS? EVERY COLONIZED PERSON
	# native americans of central america as well
	# sub saharan africans
	# south asian / india 
	
	
	#Color(0.922, 0.8, 0.671, 1), #white skin person
	#Color(0.969, 0.851, 0.78, 1), #white skin person
	#Color(0.945, 0.831, 0.725, 1), #white skin person
	#Color(0.824, 0.6, 0.424, 1),
	#Color(0.765, 0.486, 0.302, 1),
	#Color(0.714, 0.42, 0.243, 1), # ORANGE??
	#Color(0.457, 0.294, 0.196, 1), #dark orange skin person
	#Color(0.267, 0.196, 0.161, 1), #dark skin person
	#Color(0.294, 0.227, 0.184, 1), #dark skin person  
	Color(0.616, 0.427, 0.318, 1), #light brown skin person 
	Color(0.533, 0.345, 0.239, 1), #brown skin person   
	Color(0.341, 0.22, 0.176, 1), #dark skin person
]

# --- Lookup helper methods ---
static func get_color(faction: String, key: String = "primary") -> Color:
	if not FACTIONS.has(faction):
		push_warning("Invalid faction: " + faction)
		return Color(1, 1, 1, 1) # magenta for error

	# Special case: pick a random color from the list
	if faction == "Skins" and key == "primary":
		var idx = randi() % SKINS_PRIMARY_OPTIONS.size()
		return SKINS_PRIMARY_OPTIONS[idx]

	# Default behavior
	return FACTIONS[faction].get(key, Color(1, 0, 1, 1))


static func get_stat(faction: String, stat: String) -> int:
	if not FACTIONS.has(faction):
		push_warning("Invalid faction: " + faction)
		return 0
	return FACTIONS[faction].get(stat, 0)

static func get_info(faction: String) -> Dictionary:
	return FACTIONS.get(faction, {})



# FACTIONS
	#https://www.schemecolor.com/tan-on-skin-color-scheme.php
	# WHO ARE THE SKINS? EVERY COLONIZED PERSON
	# native americans of central america as well
	# sub saharan africans
	# south asian / india 
	
# FACTION AESTHETICS
#Black is the nightmares of the fearful, the image of total evil
#White is the divine of the wrath of righteousness, the image of total good
#Blue is corporate liberal; organized, agreeable, lawful, but slow, cowardly and missing that charm
#Red is the totalitarian, fierce, over-reaching, 

# FACTION STRATEGICS
	#White
		# simplistic in their ways, invincible, unquestionable
		# WEAKNESS: "fight is never over" alignment of us versus them; White turns all enemies into Black, making them stronger and all others weaker
		# WEAKNESS: One strong piece, and two pawns max- few in number
	#Black
		# STRENGTH: can use many illusions, magics, stuns
		# STRENGTH: can attack from distance
		# WEAKNESS: all enemies unite against Black
		# WEAKNESS: chaos, randomness, no strong plan "THE BANALITY OF EVIL"
	#Blue
		
	#Red
	#Skins
 
