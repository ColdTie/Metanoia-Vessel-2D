extends Control

# World Surface — walkable exploration scene for the player's current world.
# Player wanders a fixed 1280x720 field and walks into specimens to collect
# them. All UI/visuals are built in code, matching the Travel Screen's style.

const PLAY_W := 1280.0
const PLAY_H := 720.0
const TOP_MARGIN := 90.0  # keep player clear of the status bar
const MOVE_SPEED := 260.0
const PLAYER_SIZE := Vector2(26.0, 26.0)
const SPECIMEN_SIZE := Vector2(20.0, 20.0)
const COLLECT_RADIUS := 30.0

const WORLD_COLORS := {
	"temperate": Color(0.40, 0.30, 0.12),
	"ice": Color(0.72, 0.83, 0.90),
	"jungle": Color(0.07, 0.26, 0.11),
	"desert": Color(0.52, 0.34, 0.17),
	"ocean": Color(0.05, 0.22, 0.42),
}

var _world_data: Dictionary = {}
var _world_id: String = ""

var _play_root: Node2D
var _player: ColorRect
var _specimen_entries: Array = []  # {node, label, id, collected}

var _status_label: Label
var _hint_label: Label
var _message_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world_data = GameState.get_current_world_data()
	_world_id = _world_data.get("id", "")

	_build_background()
	_play_root = Node2D.new()
	_play_root.name = "PlayRoot"
	add_child(_play_root)

	_build_player()
	_spawn_specimens()
	_build_ui()
	_refresh_status()


func _process(delta: float) -> void:
	_handle_movement(delta)
	_check_pickups()


# ── World & Player ───────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = WORLD_COLORS.get(_world_data.get("type", ""), Color(0.2, 0.2, 0.25))
	add_child(bg)


func _build_player() -> void:
	_player = ColorRect.new()
	_player.name = "Player"
	_player.size = PLAYER_SIZE
	_player.color = Color(0.25, 0.9, 0.9)
	_player.position = Vector2(PLAY_W * 0.5, PLAY_H * 0.5) - PLAYER_SIZE * 0.5
	_play_root.add_child(_player)


func _spawn_specimens() -> void:
	var ids: Array = _world_data.get("specimens", [])
	for specimen_id in ids:
		var node := ColorRect.new()
		node.size = SPECIMEN_SIZE
		node.color = Color(1.0, 0.85, 0.2)
		node.position = Vector2(
			randf_range(80.0, PLAY_W - 80.0 - SPECIMEN_SIZE.x),
			randf_range(TOP_MARGIN + 20.0, PLAY_H - 40.0 - SPECIMEN_SIZE.y)
		)
		_play_root.add_child(node)

		var label := Label.new()
		label.text = String(specimen_id).capitalize()
		label.position = node.position + Vector2(-10.0, -20.0)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		_play_root.add_child(label)

		var already_collected: bool = GameState.has_specimen(specimen_id, _world_id)
		node.visible = not already_collected
		label.visible = not already_collected

		_specimen_entries.append({
			"node": node,
			"label": label,
			"id": specimen_id,
			"collected": already_collected,
		})


func _handle_movement(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		return
	_player.position += dir * MOVE_SPEED * delta
	_player.position.x = clamp(_player.position.x, 0.0, PLAY_W - PLAYER_SIZE.x)
	_player.position.y = clamp(_player.position.y, TOP_MARGIN, PLAY_H - PLAYER_SIZE.y)


func _check_pickups() -> void:
	var center: Vector2 = _player.position + PLAYER_SIZE * 0.5
	for entry in _specimen_entries:
		if entry["collected"]:
			continue
		var node: ColorRect = entry["node"]
		var specimen_center: Vector2 = node.position + SPECIMEN_SIZE * 0.5
		if center.distance_to(specimen_center) <= COLLECT_RADIUS:
			_collect(entry)


func _collect(entry: Dictionary) -> void:
	entry["collected"] = true
	entry["node"].visible = false
	entry["label"].visible = false
	if not GameState.has_specimen(entry["id"], _world_id):
		GameState.add_specimen(entry["id"], _world_id)
	SaveLoad.save_game()
	_refresh_status()


# ── UI ────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "UI"
	add_child(canvas)

	var bar := PanelContainer.new()
	bar.set_anchor(SIDE_LEFT, 0.0)
	bar.set_anchor(SIDE_TOP, 0.0)
	bar.set_anchor(SIDE_RIGHT, 1.0)
	bar.set_offset(SIDE_LEFT, 16.0)
	bar.set_offset(SIDE_TOP, 16.0)
	bar.set_offset(SIDE_RIGHT, -16.0)
	bar.set_offset(SIDE_BOTTOM, 74.0)
	canvas.add_child(bar)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	bar.add_child(row)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_col)

	_status_label = Label.new()
	text_col.add_child(_status_label)

	_hint_label = Label.new()
	_hint_label.text = "Arrow keys / WASD to move. Walk into a specimen to collect it."
	_hint_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	text_col.add_child(_hint_label)

	_message_label = Label.new()
	_message_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
	text_col.add_child(_message_label)

	var return_btn := Button.new()
	return_btn.text = "Return to Ship"
	return_btn.custom_minimum_size = Vector2(160.0, 40.0)
	return_btn.pressed.connect(_on_return_pressed)
	row.add_child(return_btn)


func _refresh_status() -> void:
	var total: int = _specimen_entries.size()
	var found: int = 0
	for entry in _specimen_entries:
		if entry["collected"]:
			found += 1
	_status_label.text = "Exploring %s — Specimens: %d / %d" % [
		_world_data.get("name", "Unknown World"), found, total
	]
	_message_label.text = "All specimens found here!" if total > 0 and found == total else ""


func _on_return_pressed() -> void:
	SaveLoad.save_game()
	get_tree().change_scene_to_file("res://scenes/travel/travel_screen.tscn")
