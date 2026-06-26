extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

# Full passive roster — 10 total (5 world-type, 5 generic) enables void unlock.
# type field biases pick_passive_choices() toward the settled world's biome.
const PASSIVE_POOL = [
	{
		"id": "founding_bonus",
		"name": "Founding Bonus",
		"desc": "The act of founding sharpens your resolve. +5 max fuel.",
		"type": "generic",
	},
	{
		"id": "echo_listener",
		"name": "Echo Listener",
		"desc": "You hear what creatures mean, not just what they say. Unlocks deeper dialogue options.",
		"type": "generic",
	},
	{
		"id": "vessel_bond",
		"name": "Vessel Bond",
		"desc": "Each founding deepens your connection. Vessels restore 10 more fuel when you visit.",
		"type": "generic",
	},
	{
		"id": "cartographer",
		"name": "Cartographer's Eye",
		"desc": "Distance loses its mystery. All world travel costs are reduced by 1 fuel.",
		"type": "generic",
	},
	{
		"id": "steady_reach",
		"name": "Steady Reach",
		"desc": "Experience steadies you. The first encounter on any world can always be avoided.",
		"type": "generic",
	},
	{
		"id": "ember_sight",
		"name": "Ember Sight",
		"desc": "Temperate warmth opens your senses. Gain 5 fuel on arrival at temperate worlds.",
		"type": "temperate",
	},
	{
		"id": "frost_hardened",
		"name": "Frost Hardened",
		"desc": "The cold no longer costs you. Ice-world travel costs 1 less fuel.",
		"type": "ice",
	},
	{
		"id": "root_knowledge",
		"name": "Root Knowledge",
		"desc": "Jungle worlds reveal their specimens more readily to you.",
		"type": "jungle",
	},
	{
		"id": "dust_walker",
		"name": "Dust Walker",
		"desc": "Desert silence teaches patience. Desert worlds never trigger forced combat.",
		"type": "desert",
	},
	{
		"id": "tide_reader",
		"name": "Tide Reader",
		"desc": "Ocean rhythms guide your eye. Reveals hidden specimens on ocean worlds.",
		"type": "ocean",
	},
]

var current_world: String = "Ardent Shore"
var passives: Array = []          # Array of {id, name, desc, source}
var ship_decorations: Array = []
var specimens: Array = []         # Array of {id, world_id, name}
var credits: int = 0
var fuel: int = 100
var max_fuel: int = 100

# World catalog — initialized in _ready(); mutated when worlds are settled.
# Each entry: {id, name, type, description, settled, vessel_name, distance, specimens}
var world_catalog: Array = []

signal world_changed(new_world: String)
signal passive_gained(passive: Dictionary)
signal credits_changed(amount: int)


func _ready() -> void:
	_build_world_catalog()


func _build_world_catalog() -> void:
	world_catalog = [
		{
			"id": "ardent_shore",
			"name": "Ardent Shore",
			"type": "temperate",
			"description": "A warm world of amber plains and shallow seas. First settlers found it welcoming — the air carries the faint smell of something like bread.",
			"settled": false,
			"vessel_name": "",
			"distance": 0,
			"specimens": ["ember_moth", "tide_crawler"],
		},
		{
			"id": "pale_drift",
			"name": "Pale Drift",
			"type": "ice",
			"description": "A frozen world adrift from its sun. Strange lights pulse beneath the ice in patterns that almost seem deliberate.",
			"settled": false,
			"vessel_name": "",
			"distance": 3,
			"specimens": ["frost_wisp", "deep_rumbler"],
		},
		{
			"id": "verdant_coil",
			"name": "Verdant Coil",
			"type": "jungle",
			"description": "Thick canopies spiral around a world still breathing from its volcanic youth. The roots here run deeper than the stone.",
			"settled": false,
			"vessel_name": "",
			"distance": 5,
			"specimens": ["canopy_singer", "root_walker"],
		},
		{
			"id": "the_hush",
			"name": "The Hush",
			"type": "desert",
			"description": "A silent world of red dust and ruins older than any known civilization. The creatures here have learned to whisper.",
			"settled": false,
			"vessel_name": "",
			"distance": 7,
			"specimens": ["sand_tender", "echo_lizard"],
		},
		{
			"id": "mirrorpool",
			"name": "Mirrorpool",
			"type": "ocean",
			"description": "Almost entirely water. The surface reflects the stars so perfectly that travelers sometimes forget which direction is up.",
			"settled": false,
			"vessel_name": "",
			"distance": 9,
			"specimens": ["lens_fish", "tide_weaver"],
		},
	]


func get_world_by_id(id: String) -> Dictionary:
	for world in world_catalog:
		if world["id"] == id:
			return world
	return {}


func get_world_by_name(name: String) -> Dictionary:
	for world in world_catalog:
		if world["name"] == name:
			return world
	return {}


func get_current_world_data() -> Dictionary:
	return get_world_by_name(current_world)


func travel_to_world(world_id: String) -> bool:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return false
	var cost: int = world.get("distance", 0)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	passive_gained.emit(passive)
	if passives.size() >= MAX_PASSIVES:
		_trigger_void_check()


func _trigger_void_check() -> void:
	# UNRESOLVED: does the replicator feed into the void endgame?
	# Do not implement without resolving that design question first.
	push_warning("GameState: 10 passives reached — void/black-hole endgame not yet implemented.")


func add_credits(amount: int) -> void:
	credits += amount
	credits_changed.emit(credits)


func spend_credits(amount: int) -> bool:
	if credits < amount:
		return false
	credits -= amount
	credits_changed.emit(credits)
	return true


func add_specimen(specimen_id: String, world_id: String) -> void:
	specimens.append({"id": specimen_id, "world_id": world_id})


func refuel(amount: int) -> void:
	fuel = min(fuel + amount, max_fuel)


# Returns up to `count` passives the player doesn't own, biased toward world_type.
func pick_passive_choices(world_type: String, count: int = 3) -> Array:
	var owned_ids: Array = []
	for p in passives:
		owned_ids.append(p["id"])

	var typed: Array = []
	var other: Array = []
	for p in PASSIVE_POOL:
		if owned_ids.has(p["id"]):
			continue
		if p.get("type", "generic") == world_type:
			typed.append(p)
		else:
			other.append(p)

	other.shuffle()

	var choices: Array = []
	if not typed.is_empty():
		choices.append(typed[0])
	for p in other:
		if choices.size() >= count:
			break
		choices.append(p)

	choices.shuffle()
	return choices
