extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

# Full passive roster (see design/systems.md). Drawn 3-at-a-time on settling;
# player picks one. Effects not yet hookable (combat/dialogue/specimen
# systems still TODO) are recorded but only take mechanical effect once
# their system exists.
const PASSIVE_POOL: Array = [
	{"id": "founding_bonus", "name": "Founding Bonus", "desc": "First settlement — +5 max fuel."},
	{"id": "root_knowledge", "name": "Root Knowledge", "desc": "Jungle worlds yield extra specimens."},
	{"id": "echo_listener", "name": "Echo Listener", "desc": "Unlocks extra creature dialogue options."},
	{"id": "frost_hardened", "name": "Frost Hardened", "desc": "Ice-world travel costs 1 less fuel."},
	{"id": "tide_reader", "name": "Tide Reader", "desc": "Ocean worlds reveal hidden specimens."},
	{"id": "dust_walker", "name": "Dust Walker", "desc": "Desert worlds never trigger forced combat."},
	{"id": "quiet_diplomat", "name": "Quiet Diplomat", "desc": "Talk outcomes with hostile creatures succeed more often."},
	{"id": "steady_hands", "name": "Steady Hands", "desc": "Combat encounters are less likely to end in retreat."},
	{"id": "deep_reserves", "name": "Deep Reserves", "desc": "+5 max fuel."},
	{"id": "star_chartered", "name": "Star-Chartered", "desc": "Travel to any world costs 1 less fuel."},
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
	var cost: int = _apply_travel_discounts(world.get("distance", 0), world)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func _apply_travel_discounts(base_cost: int, world: Dictionary) -> int:
	var cost := base_cost
	if cost <= 0:
		return cost
	if has_passive("star_chartered"):
		cost -= 1
	if world.get("type", "") == "ice" and has_passive("frost_hardened"):
		cost -= 1
	return max(cost, 0)


func has_passive(id: String) -> bool:
	for passive in passives:
		if passive.get("id", "") == id:
			return true
	return false


# Returns up to `count` passives drawn from the pool, excluding ones already
# owned. If `force_id` names an unowned pool entry, it is guaranteed a slot
# (used to surface Founding Bonus on a player's first settlement).
func draw_passive_choices(count: int = 3, force_id: String = "") -> Array:
	var available: Array = PASSIVE_POOL.filter(func(p): return not has_passive(p["id"]))
	available.shuffle()

	var choices: Array = []
	if not force_id.is_empty():
		for p in available:
			if p["id"] == force_id:
				choices.append(p)
				available.erase(p)
				break

	while choices.size() < count and not available.is_empty():
		choices.append(available.pop_back())
	return choices


# Grants a passive drawn from PASSIVE_POOL, tagging it with its source world,
# and applies whatever mechanical effect it has today (see PASSIVE_POOL note).
func grant_passive(passive_def: Dictionary, source: String) -> void:
	var passive: Dictionary = passive_def.duplicate()
	passive["source"] = source
	add_passive(passive)
	_apply_passive_effect(passive["id"])


func _apply_passive_effect(id: String) -> void:
	match id:
		"founding_bonus", "deep_reserves":
			max_fuel += 5
			refuel(5)
		_:
			pass  # narrative / future-system hook — see design/systems.md


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
