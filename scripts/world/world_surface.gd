extends Node2D

# World Surface — walkable exploration scene for the player's current world.
# Move with arrow keys / WASD, walk into a specimen to collect it.
# All UI/visuals built in code, matching the travel screen's approach.

const MOVE_SPEED := 260.0
const PLAYER_SIZE := Vector2(28.0, 28.0)
const PICKUP_SIZE := Vector2(18.0, 18.0)
const COLLECT_RADIUS := 26.0
const VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const PICKUP_SPOTS: Array = [
	Vector2(260.0, 180.0),
	Vector2(1000.0, 200.0),
	Vector2(260.0, 540.0),
	Vector2(1000.0, 540.0),
]

const TYPE_COLORS := {
	"temperate": Color(0.55, 0.4, 0.18),
	"ice": Color(0.75, 0.85, 0.92),
	"jungle": Color(0.12, 0.32, 0.14),
	"desert": Color(0.5, 0.28, 0.12),
	"ocean": Color(0.08, 0.2, 0.38),
}

var _world: Dictionary = {}
var _player: ColorRect
var _pickups: Array = []  # Array of {node, id, name}
var _found_count: int = 0
var _total_count: int = 0

var _status_label: Label
var _toast_label: Label
var _toast_timer: float = 0.0


func _ready() -> void:
	_world = GameState.get_current_world_data()
	_build_background()
	_build_player()
	_build_pickups()
	_build_ui()
	_update_status()


func _process(delta: float) -> void:
	_move_player(delta)
	_check_pickups()
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast_label.text = ""


# ── Setup ─────────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.size = VIEWPORT_SIZE
	var world_type: String = _world.get("type", "temperate")
	bg.color = TYPE_COLORS.get(world_type, Color(0.1, 0.1, 0.15))
	add_child(bg)


func _build_player() -> void:
	_player = ColorRect.new()
	_player.size = PLAYER_SIZE
	_player.color = Color(1.0, 0.95, 0.6)
	_player.position = VIEWPORT_SIZE / 2.0 - PLAYER_SIZE / 2.0
	add_child(_player)


func _build_pickups() -> void:
	var specimen_ids: Array = _world.get("specimens", [])
	var world_id: String = _world.get("id", "")
	_total_count = specimen_ids.size()
	_found_count = 0

	for i in specimen_ids.size():
		var specimen_id: String = specimen_ids[i]
		if _already_collected(specimen_id, world_id):
			_found_count += 1
			continue
		var spot: Vector2 = PICKUP_SPOTS[i % PICKUP_SPOTS.size()]
		var pickup := ColorRect.new()
		pickup.size = PICKUP_SIZE
		pickup.color = Color(1.0, 0.8, 0.2)
		pickup.position = spot - PICKUP_SIZE / 2.0
		add_child(pickup)
		_pickups.append({"node": pickup, "id": specimen_id})


func _already_collected(specimen_id: String, world_id: String) -> bool:
	for s in GameState.specimens:
		if s.get("id", "") == specimen_id and s.get("world_id", "") == world_id:
			return true
	return false


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(16.0, 16.0)
	root.add_child(vbox)

	var title := Label.new()
	title.text = "Exploring: " + _world.get("name", "Unknown")
	vbox.add_child(title)

	_status_label = Label.new()
	vbox.add_child(_status_label)

	_toast_label = Label.new()
	_toast_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
	vbox.add_child(_toast_label)

	var return_button := Button.new()
	return_button.text = "Return to Ship"
	return_button.mouse_filter = Control.MOUSE_FILTER_STOP
	return_button.size = Vector2(160.0, 40.0)
	return_button.position = Vector2(VIEWPORT_SIZE.x - 176.0, VIEWPORT_SIZE.y - 56.0)
	return_button.pressed.connect(_on_return_pressed)
	root.add_child(return_button)


# ── Logic ─────────────────────────────────────────────────────────────────────

func _move_player(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_player.position += dir * MOVE_SPEED * delta
	_player.position = _player.position.clamp(Vector2.ZERO, VIEWPORT_SIZE - PLAYER_SIZE)


func _check_pickups() -> void:
	var player_center: Vector2 = _player.position + PLAYER_SIZE / 2.0
	for entry in _pickups.duplicate():
		var node: ColorRect = entry["node"]
		var pickup_center: Vector2 = node.position + PICKUP_SIZE / 2.0
		if player_center.distance_to(pickup_center) <= COLLECT_RADIUS:
			_collect(entry)


func _collect(entry: Dictionary) -> void:
	var specimen_id: String = entry["id"]
	var world_id: String = _world.get("id", "")
	GameState.add_specimen(specimen_id, world_id)
	entry["node"].queue_free()
	_pickups.erase(entry)
	_found_count += 1
	_toast_label.text = "Collected: " + specimen_id.replace("_", " ").capitalize()
	_toast_timer = 2.5
	_update_status()
	SaveLoad.save_game()


func _update_status() -> void:
	_status_label.text = "Specimens found: %d / %d" % [_found_count, _total_count]


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/travel/travel_screen.tscn")
