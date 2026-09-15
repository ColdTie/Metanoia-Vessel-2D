extends Node

const SAVE_PATH := "user://save.json"


func save_game() -> void:
	var data := {
		"version": 1,
		"current_world": GameState.current_world,
		"passives": GameState.passives,
		"passive_pool": GameState.passive_pool,
		"ship_decorations": GameState.ship_decorations,
		"specimens": GameState.specimens,
		"credits": GameState.credits,
		"fuel": GameState.fuel,
		"settled_worlds": _get_settled_worlds(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveLoad: could not open %s for writing." % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("SaveLoad: JSON parse error in save file.")
		return false
	var data: Dictionary = json.get_data()
	GameState.current_world = data.get("current_world", "Ardent Shore")
	GameState.passives = data.get("passives", [])
	GameState.passive_pool = data.get("passive_pool", GameState.passive_pool)
	GameState.ship_decorations = data.get("ship_decorations", [])
	GameState.specimens = data.get("specimens", [])
	GameState.credits = data.get("credits", 0)
	GameState.fuel = data.get("fuel", 100)
	_restore_settled_worlds(data.get("settled_worlds", []))
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _get_settled_worlds() -> Array:
	var settled: Array = []
	for world in GameState.world_catalog:
		if world.get("settled", false):
			settled.append({
				"id": world["id"],
				"vessel_name": world.get("vessel_name", ""),
			})
	return settled


func _restore_settled_worlds(settled: Array) -> void:
	for entry in settled:
		for world in GameState.world_catalog:
			if world["id"] == entry.get("id", ""):
				world["settled"] = true
				world["vessel_name"] = entry.get("vessel_name", "")
