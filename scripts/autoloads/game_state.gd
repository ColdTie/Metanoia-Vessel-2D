extends Node

# Singleton: all mutable game state. Access via GameState.x anywhere.

const MAX_PASSIVES := 10  # Reaching this triggers void unlock check

# Full passive pool — draw from here at settlement. Effects noted per entry;
# stat effects applied in _apply_passive_effect(); exploration effects activate
# when world surface scenes land.
const PASSIVE_POOL: Array = [
	{
		"id": "founding_bonus",
		"name": "Founding Bonus",
		"desc": "The act of founding grants clarity. [b]+5 max fuel.[/b]",
		"source": "",
	},
	{
		"id": "frost_hardened",
		"name": "Frost Hardened",
		"desc": "Cold passages no longer bite as deep. [b]Ice-world travel costs 1 less fuel.[/b]",
		"source": "",
	},
	{
		"id": "root_knowledge",
		"name": "Root Knowledge",
		"desc": "The jungle speaks to those who listen. Yields extra specimens on jungle worlds.",
		"source": "",
	},
	{
		"id": "echo_listener",
		"name": "Echo Listener",
		"desc": "Silences become sentences. Unlocks additional dialogue paths with creatures.",
		"source": "",
	},
	{
		"id": "tide_reader",
		"name": "Tide Reader",
		"desc": "The currents reveal what the surface hides. Reveals hidden specimens on ocean worlds.",
		"source": "",
	},
	{
		"id": "dust_walker",
		"name": "Dust Walker",
		"desc": "The desert taught patience. Desert worlds never trigger forced encounters.",
		"source": "",
	},
	{
		"id": "stellar_cartography",
		"name": "Stellar Cartography",
		"desc": "Every charted star is a shortcut waiting to be seen. [b]All travel costs 1 less fuel.[/b]",
		"source": "",
	},
	{
		"id": "vessel_blessing",
		"name": "Vessel Blessing",
		"desc": "Each Vessel you found amplifies the next. Settled worlds refuel 5 more on docking.",
		"source": "",
	},
	{
		"id": "canopy_bond",
		"name": "Canopy Bond",
		"desc": "Life recognises life. Arriving on temperate or jungle worlds grants [b]+2 credits.[/b]",
		"source": "",
	},
	{
		"id": "deep_resonance",
		"name": "Deep Resonance",
		"desc": "Water remembers everything. Doubles specimen find chance on ocean worlds.",
		"source": "",
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
	if _has_passive("stellar_cartography"):
		cost = max(0, cost - 1)
	if world.get("type") == "ice" and _has_passive("frost_hardened"):
		cost = max(0, cost - 1)
	if fuel < cost:
		return false
	fuel -= cost
	# canopy_bond: +2 credits on arrival at temperate or jungle worlds
	if _has_passive("canopy_bond") and world.get("type") in ["temperate", "jungle"]:
		add_credits(2)
	current_world = world["name"]
	world_changed.emit(current_world)
	return true


func _has_passive(passive_id: String) -> bool:
	for p in passives:
		if p.get("id") == passive_id:
			return true
	return false


func draw_passive_choices(n: int = 3) -> Array:
	var owned_ids: Array = passives.map(func(p: Dictionary) -> String: return p.get("id", ""))
	var pool: Array = PASSIVE_POOL.filter(
		func(p: Dictionary) -> bool: return not owned_ids.has(p.get("id", ""))
	)
	pool.shuffle()
	return pool.slice(0, min(n, pool.size()))


func add_passive(passive: Dictionary) -> void:
	passives.append(passive)
	_apply_passive_effect(passive)
	passive_gained.emit(passive)
	if passives.size() >= MAX_PASSIVES:
		_trigger_void_check()


func _apply_passive_effect(passive: Dictionary) -> void:
	match passive.get("id", ""):
		"founding_bonus":
			max_fuel += 5
			refuel(5)
		# frost_hardened, stellar_cartography: applied dynamically in travel_to_world()
		# canopy_bond: applied dynamically in travel_to_world()
		# exploration-dependent passives activate when world surface scenes land
		_:
			pass


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
