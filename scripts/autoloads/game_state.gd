extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

# Full passive roster. Settling draws 3 at random (excluding already-owned)
# for the player to choose from. Keep in sync with design/systems.md.
const PASSIVE_POOL: Array = [
	{"id": "founding_bonus", "name": "Founding Bonus", "desc": "The act of founding grants clarity. +5 max fuel."},
	{"id": "root_knowledge", "name": "Root Knowledge", "desc": "Jungle worlds yield extra specimens."},
	{"id": "echo_listener", "name": "Echo Listener", "desc": "Unlocks extra creature dialogue options."},
	{"id": "frost_hardened", "name": "Frost Hardened", "desc": "Ice-world travel costs 1 less fuel."},
	{"id": "tide_reader", "name": "Tide Reader", "desc": "Ocean worlds reveal hidden specimens."},
	{"id": "dust_walker", "name": "Dust Walker", "desc": "Desert worlds never trigger forced combat."},
	{"id": "warm_current", "name": "Warm Current", "desc": "Temperate worlds refill 2 extra fuel on arrival."},
	{"id": "still_hands", "name": "Still Hands", "desc": "Talk outcomes with wary creatures succeed more easily."},
	{"id": "deep_charting", "name": "Deep Charting", "desc": "Reveals a world's specimens before you land there."},
	{"id": "quiet_holds", "name": "Quiet Holds", "desc": "Ship decorations cost 10% fewer credits."},
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


func get_passive_draw(count: int = 3) -> Array:
	var owned_ids: Array = []
	for p in passives:
		owned_ids.append(p.get("id", ""))
	var available: Array = PASSIVE_POOL.filter(
		func(p): return not owned_ids.has(p["id"])
	)
	available.shuffle()
	var draw: Array = available.slice(0, min(count, available.size()))
	for i in draw.size():
		draw[i] = draw[i].duplicate()  # PASSIVE_POOL entries are read-only constants
	return draw


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	passive_gained.emit(passive)
	_apply_passive_effect(passive)
	if passives.size() >= MAX_PASSIVES:
		_trigger_void_check()


func _apply_passive_effect(passive: Dictionary) -> void:
	# Only mechanically-wired effects live here; the rest are flavor until
	# their underlying systems (specimens, dialogue, combat) exist.
	match passive.get("id", ""):
		"founding_bonus":
			max_fuel += 5
			refuel(5)


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
