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


func get_travel_cost(world_id: String) -> int:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return 0
	var cost: int = world.get("distance", 0)
	if cost > 0:
		if _has_passive("cartographer"):
			cost -= 1
		if _has_passive("frost_hardened") and world.get("type", "") == "ice":
			cost -= 1
		cost = max(1, cost)
	return cost


func travel_to_world(world_id: String) -> bool:
	var world := get_world_by_id(world_id)
	if world.is_empty():
		return false
	var cost: int = get_travel_cost(world_id)
	if fuel < cost:
		return false
	fuel -= cost
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	_apply_passive_effect(passive.get("id", ""))
	passive_gained.emit(passive)
	if passives.size() >= MAX_PASSIVES:
		_trigger_void_check()


func _apply_passive_effect(passive_id: String) -> void:
	match passive_id:
		"founding_bonus":
			max_fuel += 5
			refuel(5)
		# cartographer and frost_hardened are applied at travel time via get_travel_cost
		# other passives take effect when encounter/exploration systems exist


func _trigger_void_check() -> void:
	# UNRESOLVED: does the replicator feed into the void endgame?
	# Do not implement without resolving that design question first.
	push_warning("GameState: 10 passives reached — void/black-hole endgame not yet implemented.")


func _has_passive(passive_id: String) -> bool:
	for p in passives:
		if p.get("id", "") == passive_id:
			return true
	return false


# Returns up to `count` passives from the roster, excluding already-owned ones.
func draw_passive_options(count: int) -> Array:
	var roster := _passive_roster()
	var owned_ids: Array = passives.map(func(p: Dictionary) -> String: return p.get("id", ""))
	var available: Array = roster.filter(
		func(p: Dictionary) -> bool: return not owned_ids.has(p.get("id", ""))
	)
	available.shuffle()
	return available.slice(0, min(count, available.size()))


func _passive_roster() -> Array:
	return [
		{
			"id": "founding_bonus",
			"name": "Founding Bonus",
			"desc": "The act of founding opens something. +5 max fuel.",
			"source": "",
		},
		{
			"id": "root_knowledge",
			"name": "Root Knowledge",
			"desc": "Jungle worlds feel intuitive now. They yield extra specimens during exploration.",
			"source": "",
		},
		{
			"id": "echo_listener",
			"name": "Echo Listener",
			"desc": "You have learned to pause before speaking. Unlocks extra dialogue options with creatures.",
			"source": "",
		},
		{
			"id": "frost_hardened",
			"name": "Frost Hardened",
			"desc": "The cold no longer drains you. Ice-world travel costs 1 less fuel.",
			"source": "",
		},
		{
			"id": "tide_reader",
			"name": "Tide Reader",
			"desc": "You sense the pull of deep water. Ocean worlds reveal hidden specimens.",
			"source": "",
		},
		{
			"id": "dust_walker",
			"name": "Dust Walker",
			"desc": "You move through silence as if you belong there. Desert worlds never trigger forced combat.",
			"source": "",
		},
		{
			"id": "void_compass",
			"name": "Void Compass",
			"desc": "A quiet pull toward what is hidden. Occasionally surface +3 fuel during exploration.",
			"source": "",
		},
		{
			"id": "still_mind",
			"name": "Still Mind",
			"desc": "Calm in the face of strangeness. Avoidance options never cost extra resources.",
			"source": "",
		},
		{
			"id": "vessel_bond",
			"name": "Vessel Bond",
			"desc": "Your Vessels feel like extensions of yourself. Each provides +3 extra fuel on refill.",
			"source": "",
		},
		{
			"id": "cartographer",
			"name": "Cartographer",
			"desc": "Every route feels charted now. All travel costs reduced by 1 (minimum 1).",
			"source": "",
		},
	]


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
