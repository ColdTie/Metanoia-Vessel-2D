extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

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

# Passives offered via choose-1-of-3 on second-and-later settlements.
# founding_bonus is excluded — it is granted automatically on the first
# settlement only, and is never part of this drawn pool.
var passive_roster: Array = []

signal world_changed(new_world: String)
signal passive_gained(passive: Dictionary)
signal credits_changed(amount: int)


func _ready() -> void:
	_build_world_catalog()
	_build_passive_roster()


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


func _build_passive_roster() -> void:
	passive_roster = [
		{
			"id": "root_knowledge",
			"name": "Root Knowledge",
			"desc": "Jungle worlds yield extra specimens.",
		},
		{
			"id": "echo_listener",
			"name": "Echo Listener",
			"desc": "Unlocks extra creature dialogue options.",
		},
		{
			"id": "frost_hardened",
			"name": "Frost Hardened",
			"desc": "Ice-world travel costs 1 less fuel.",
		},
		{
			"id": "tide_reader",
			"name": "Tide Reader",
			"desc": "Ocean worlds reveal hidden specimens.",
		},
		{
			"id": "dust_walker",
			"name": "Dust Walker",
			"desc": "Desert worlds never trigger forced combat.",
		},
		{
			"id": "deep_diver",
			"name": "Deep Diver",
			"desc": "Ocean-world travel costs 1 less fuel.",
		},
		{
			"id": "warm_current",
			"name": "Warm Current",
			"desc": "Arriving at a temperate world refuels 2 extra fuel.",
		},
		{
			"id": "canopy_guide",
			"name": "Canopy Guide",
			"desc": "Jungle creatures always offer a talk option, even hostile ones.",
		},
		{
			"id": "stellar_cartographer",
			"name": "Stellar Cartographer",
			"desc": "All travel costs 1 less fuel (minimum 1).",
		},
	]


func has_passive(id: String) -> bool:
	for p in passives:
		if p.get("id", "") == id:
			return true
	return false


# Draws up to `count` unique passives from the roster, excluding any the
# player already owns. Used to populate the choose-1-of-3 settling reward.
func draw_passive_choices(count: int = 3) -> Array:
	var pool: Array = []
	for p in passive_roster:
		if not has_passive(p["id"]):
			pool.append(p)
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))


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


func get_travel_cost(world_id: String) -> int:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return 0
	return _travel_cost_with_passives(world)


func travel_to_world(world_id: String) -> bool:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return false
	var cost: int = _travel_cost_with_passives(world)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func _travel_cost_with_passives(world: Dictionary) -> int:
	var cost: int = world.get("distance", 0)
	if cost <= 0:
		return cost
	if has_passive("stellar_cartographer"):
		cost -= 1
	if world.get("type", "") == "ice" and has_passive("frost_hardened"):
		cost -= 1
	if world.get("type", "") == "ocean" and has_passive("deep_diver"):
		cost -= 1
	return max(cost, 1)


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
