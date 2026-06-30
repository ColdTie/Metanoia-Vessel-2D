extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

# Full passive catalog — 10 entries, enough to reach the void.
# world_types: [] means any world; otherwise biased toward those types in draws.
const PASSIVE_CATALOG: Array = [
	{
		"id": "founding_bonus",
		"name": "Founding Bonus",
		"desc": "The act of founding grants clarity. +5 max fuel.",
		"world_types": [],
	},
	{
		"id": "root_knowledge",
		"name": "Root Knowledge",
		"desc": "Jungle worlds stir the memory of deeper things. Specimens from jungle worlds count double.",
		"world_types": ["jungle"],
	},
	{
		"id": "echo_listener",
		"name": "Echo Listener",
		"desc": "You learn to hear what isn't said. Unlocks extra dialogue options in creature encounters.",
		"world_types": ["desert"],
	},
	{
		"id": "frost_hardened",
		"name": "Frost Hardened",
		"desc": "Cold clarifies your needs. Ice-world travel costs 1 less fuel.",
		"world_types": ["ice"],
	},
	{
		"id": "tide_reader",
		"name": "Tide Reader",
		"desc": "The ocean teaches patience. Hidden specimens reveal themselves on ocean worlds.",
		"world_types": ["ocean"],
	},
	{
		"id": "dust_walker",
		"name": "Dust Walker",
		"desc": "Desert silence teaches a different kind of courage. Desert worlds never trigger forced combat.",
		"world_types": ["desert"],
	},
	{
		"id": "amber_sails",
		"name": "Amber Sails",
		"desc": "Temperate warmth steadies the spirit. Arriving at any temperate world recovers +3 fuel.",
		"world_types": ["temperate"],
	},
	{
		"id": "deep_cartographer",
		"name": "Deep Cartographer",
		"desc": "Every settled world becomes a known harbor. Return trips to settled worlds cost 1 less fuel.",
		"world_types": [],
	},
	{
		"id": "specimen_eye",
		"name": "Specimen Eye",
		"desc": "You have learned to look for life where others miss it. Find one extra specimen per world visited.",
		"world_types": [],
	},
	{
		"id": "still_core",
		"name": "Still Core",
		"desc": "The Vessel hum settles something in you. Each new Vessel founding recovers +10 fuel.",
		"world_types": [],
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


# Returns up to `count` passive options for a settling reward draw.
# Biases toward passives matching world_type; fills from generic pool.
# Excludes passives the player already owns.
func draw_passive_options(world_type: String, count: int = 3) -> Array:
	var owned_ids: Array = passives.map(func(p): return p["id"])
	var available: Array = PASSIVE_CATALOG.filter(
		func(p): return not owned_ids.has(p["id"])
	)
	var typed: Array = available.filter(
		func(p): return p["world_types"].has(world_type)
	)
	var generic: Array = available.filter(
		func(p): return p["world_types"].is_empty()
	)
	var other: Array = available.filter(func(p):
		return not p["world_types"].is_empty() and not p["world_types"].has(world_type)
	)
	typed.shuffle()
	generic.shuffle()
	other.shuffle()
	# Typed first, then generic fillers, then cross-type as last resort
	var pool: Array = typed + generic + other
	return pool.slice(0, count)


func has_passive(passive_id: String) -> bool:
	for p in passives:
		if p.get("id", "") == passive_id:
			return true
	return false


func travel_to_world(world_id: String) -> bool:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return false
	var cost: int = _get_travel_cost(world)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	_apply_arrival_effects(world)
	world_changed.emit(current_world)
	return true


func _get_travel_cost(world: Dictionary) -> int:
	var cost: int = world.get("distance", 0)
	if world.get("type", "") == "ice" and has_passive("frost_hardened"):
		cost = max(0, cost - 1)
	if world.get("settled", false) and has_passive("deep_cartographer"):
		cost = max(0, cost - 1)
	return cost


func _apply_arrival_effects(world: Dictionary) -> void:
	if world.get("type", "") == "temperate" and has_passive("amber_sails"):
		refuel(3)


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	_apply_passive_on_gain(passive)
	passive_gained.emit(passive)
	if passives.size() >= MAX_PASSIVES:
		_trigger_void_check()


func _apply_passive_on_gain(passive: Dictionary) -> void:
	match passive.get("id", ""):
		"founding_bonus":
			max_fuel += 5
			refuel(5)
		"still_core":
			refuel(10)


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
