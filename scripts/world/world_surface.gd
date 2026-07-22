extends Control

# World Surface — walkable exploration scene for a single world.
# GameState.exploring_world_id selects which world to load before this
# scene is entered (set by travel_screen's "Explore Surface" button).
# Placeholder visuals: colored rects for player and specimens.
# No creatures/combat yet — that is a future increment.

const PLAYER_SPEED := 260.0
const PLAYER_SIZE := Vector2(22.0, 22.0)
const SPECIMEN_SIZE := Vector2(16.0, 16.0)
const PICKUP_RADIUS := 24.0
const FIELD_TOP := 96.0
const FIELD_MARGIN := 16.0

var _world_id: String = ""
var _world_data: Dictionary = {}
var _play_field: Node2D
var _player: ColorRect
var _specimen_nodes: Dictionary = {}  # specimen_id -> ColorRect
var _total_specimens: int = 0
var _status_label: Label
var _message_label: RichTextLabel
var _field_rect: Rect2


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world_id = GameState.exploring_world_id
	_world_data = GameState.get_world_by_id(_world_id)
	_build_background()
	_build_hud()
	_build_play_field()
	_compute_field_rect()
	_spawn_player()
	_spawn_specimens()
	_update_status()


func _process(delta: float) -> void:
	_move_player(delta)
	_check_pickups()


# ── Setup ─────────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = _ground_color()
	add_child(bg)


func _ground_color() -> Color:
	match _world_data.get("type", ""):
		"ice":
			return Color(0.72, 0.83, 0.93)
		"jungle":
			return Color(0.09, 0.26, 0.11)
		"desert":
			return Color(0.55, 0.42, 0.20)
		"ocean":
			return Color(0.07, 0.20, 0.34)
		_:
			return Color(0.36, 0.28, 0.13)


func _build_hud() -> void:
	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT, 0.0)
	panel.set_anchor(SIDE_TOP, 0.0)
	panel.set_anchor(SIDE_RIGHT, 1.0)
	panel.set_offset(SIDE_LEFT, 16.0)
	panel.set_offset(SIDE_TOP, 16.0)
	panel.set_offset(SIDE_RIGHT, -16.0)
	panel.set_offset(SIDE_BOTTOM, FIELD_TOP - 16.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	var title := Label.new()
	title.text = str(_world_data.get("name", "Unknown World")) + " — Surface"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title)

	_status_label = Label.new()
	_status_label.text = "Specimens: 0/0"
	hbox.add_child(_status_label)

	var return_btn := Button.new()
	return_btn.text = "Return to Ship"
	return_btn.pressed.connect(_on_return_pressed)
	hbox.add_child(return_btn)

	_message_label = RichTextLabel.new()
	_message_label.bbcode_enabled = true
	_message_label.fit_content = true
	_message_label.custom_minimum_size = Vector2(0.0, 20.0)
	_message_label.text = "[color=#cccccc]Move with WASD / Arrow Keys. Walk into a specimen to collect it.[/color]"
	vbox.add_child(_message_label)


func _build_play_field() -> void:
	_play_field = Node2D.new()
	_play_field.name = "PlayField"
	add_child(_play_field)


func _compute_field_rect() -> void:
	var vp: Vector2 = get_viewport_rect().size
	_field_rect = Rect2(
		Vector2(FIELD_MARGIN, FIELD_TOP),
		Vector2(vp.x - FIELD_MARGIN * 2.0, vp.y - FIELD_TOP - FIELD_MARGIN)
	)


func _spawn_player() -> void:
	_player = ColorRect.new()
	_player.size = PLAYER_SIZE
	_player.color = Color(1.0, 0.85, 0.3)
	var field_center: Vector2 = _field_rect.position + _field_rect.size * 0.5
	_player.position = field_center - PLAYER_SIZE * 0.5
	_play_field.add_child(_player)


func _spawn_specimens() -> void:
	var catalog: Array = _world_data.get("specimens", [])
	var collected: Array = GameState.get_collected_specimen_ids(_world_id)
	_total_specimens = catalog.size()

	for i in catalog.size():
		var specimen_id: String = catalog[i]
		if collected.has(specimen_id):
			continue
		var node := ColorRect.new()
		node.size = SPECIMEN_SIZE
		node.color = Color(0.4, 0.9, 0.6) if i % 2 == 0 else Color(0.6, 0.6, 0.95)
		node.position = _random_field_point()
		_play_field.add_child(node)

		var label := Label.new()
		label.text = specimen_id.replace("_", " ")
		label.position = Vector2(-10.0, -18.0)
		node.add_child(label)

		_specimen_nodes[specimen_id] = node


func _random_field_point() -> Vector2:
	return Vector2(
		_field_rect.position.x + randf() * (_field_rect.size.x - SPECIMEN_SIZE.x),
		_field_rect.position.y + randf() * (_field_rect.size.y - SPECIMEN_SIZE.y)
	)


# ── Movement & Collection ──────────────────────────────────────────────────────

func _move_player(delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_up", "ui_down")
	if dir.length() > 0.0:
		dir = dir.normalized()
	_player.position += dir * PLAYER_SPEED * delta
	_player.position.x = clamp(
		_player.position.x, _field_rect.position.x, _field_rect.end.x - PLAYER_SIZE.x
	)
	_player.position.y = clamp(
		_player.position.y, _field_rect.position.y, _field_rect.end.y - PLAYER_SIZE.y
	)


func _check_pickups() -> void:
	var player_center: Vector2 = _player.position + PLAYER_SIZE * 0.5
	for specimen_id in _specimen_nodes.keys().duplicate():
		var node: ColorRect = _specimen_nodes[specimen_id]
		var node_center: Vector2 = node.position + SPECIMEN_SIZE * 0.5
		if player_center.distance_to(node_center) <= PICKUP_RADIUS:
			_collect_specimen(specimen_id, node)


func _collect_specimen(specimen_id: String, node: ColorRect) -> void:
	GameState.add_specimen(specimen_id, _world_id)
	_specimen_nodes.erase(specimen_id)
	node.queue_free()
	_update_status()
	_message_label.text = "[color=#aaffaa]Collected: %s[/color]" % specimen_id.replace("_", " ")
	SaveLoad.save_game()

	if _specimen_nodes.is_empty():
		_message_label.text += "  [color=#cccccc](All specimens found on this world.)[/color]"


func _update_status() -> void:
	var collected: int = _total_specimens - _specimen_nodes.size()
	_status_label.text = "Specimens: %d/%d" % [collected, _total_specimens]


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/travel/travel_screen.tscn")
