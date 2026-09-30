extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check
const BASE_MAX_FUEL := 100
const CHOICES_PER_SETTLE := 3

# Passives that can be offered on settling. Effects marked "pending" have no
# hook yet because the systems they touch (exploration, encounters) don't exist.
const PASSIVE_ROSTER: Array = [
	{"id": "founding_bonus", "name": "Founding Bonus", "desc": "The act of founding grants clarity. +5 max fuel."},
	{"id": "frost_hardened", "name": "Frost Hardened", "desc": "Ice-world travel costs 1 less fuel."},
	{"id": "root_knowledge", "name": "Root Knowledge", "desc": "Jungle worlds yield extra specimens. (effect pending)"},
	{"id": "echo_listener", "name": "Echo Listener", "desc": "Unlocks extra creature dialogue options. (effect pending)"},
	{"id": "tide_reader", "name": "Tide Reader", "desc": "Ocean worlds reveal hidden specimens. (effect pending)"},
	{"id": "dust_walker", "name": "Dust Walker", "desc": "Desert worlds never trigger forced combat. (effect pending)"},
]

var current_world: String = "Ardent Shore"
var passives: Array = []          # Array of {id, name, desc, source}
var ship_decorations: Array = []
var specimens: Array = []         # Array of {id, world_id, name}
var credits: int = 0
var fuel: int = 100
var max_fuel: int = BASE_MAX_FUEL  # derived from passives; see sync_max_fuel()

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
	var cost := get_travel_cost(world)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func has_passive(id: String) -> bool:
	for p in passives:
		if p.get("id", "") == id:
			return true
	return false


# Fuel cost to reach a world, after passive modifiers. Never below 1 for a real trip.
func get_travel_cost(world: Dictionary) -> int:
	var cost: int = world.get("distance", 0)
	if cost > 0 and world.get("type", "") == "ice" and has_passive("frost_hardened"):
		cost = max(cost - 1, 1)
	return cost


# Recompute max_fuel from passives (so it never needs saving) and clamp fuel.
# Returns how much max_fuel grew.
func sync_max_fuel() -> int:
	var old := max_fuel
	max_fuel = BASE_MAX_FUEL + (5 if has_passive("founding_bonus") else 0)
	fuel = min(fuel, max_fuel)
	return max_fuel - old


# Up to `count` distinct roster passives the player doesn't own yet, random order.
func draw_passive_choices(count: int = CHOICES_PER_SETTLE) -> Array:
	var pool: Array = []
	for entry in PASSIVE_ROSTER:
		if not has_passive(entry["id"]):
			pool.append(entry)
	pool.shuffle()
	return pool.slice(0, count)


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	var gained := sync_max_fuel()
	if gained > 0:
		refuel(gained)
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
