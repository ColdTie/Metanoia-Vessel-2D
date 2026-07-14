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

# General settling-reward pool for the choose-1-of-3 draw. founding_bonus is
# granted automatically on the player's first settlement and is not in this
# pool. Entries are removed as they're chosen so each passive is granted once.
var passive_pool: Array = []

signal world_changed(new_world: String)
signal passive_gained(passive: Dictionary)
signal credits_changed(amount: int)


func _ready() -> void:
	_build_world_catalog()
	_build_passive_pool()


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


func _build_passive_pool() -> void:
	passive_pool = [
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
	]


# Removes any pool entries whose id is already owned. Call after loading a
# save so passives granted in a previous session aren't offered again.
func sync_passive_pool_with_owned() -> void:
	var owned_ids: Array = []
	for p in passives:
		owned_ids.append(p.get("id", ""))
	passive_pool = passive_pool.filter(func(entry): return not owned_ids.has(entry["id"]))


# Returns up to `count` random passives from the pool without removing them.
# The caller grants one of the returned choices via grant_passive_from_pool().
func draw_passive_choices(count: int = 3) -> Array:
	var pool_copy: Array = passive_pool.duplicate()
	pool_copy.shuffle()
	return pool_copy.slice(0, min(count, pool_copy.size()))


# Grants the chosen passive and removes it from the pool so it can't recur.
func grant_passive_from_pool(passive_id: String, source: String) -> void:
	for i in passive_pool.size():
		if passive_pool[i]["id"] == passive_id:
			var chosen: Dictionary = passive_pool[i]
			passive_pool.remove_at(i)
			add_passive({
				"id": chosen["id"],
				"name": chosen["name"],
				"desc": chosen["desc"],
				"source": source,
			})
			return


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
