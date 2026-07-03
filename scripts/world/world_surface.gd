extends Node2D

# World Surface — walkable exploration scene.
# Player wanders a bounded patch of the current world and collects
# specimens by walking near them. Encounters/creatures/combat: TODO.
# All visuals are placeholder shapes drawn via CanvasItem.draw();
# swap in assets/sprites/ art later without touching this logic.

const WORLD_SIZE := Vector2(2200.0, 1400.0)
const EDGE_MARGIN := 60.0
const PLAYER_SPEED := 280.0
const PLAYER_RADIUS := 16.0
const COLLECT_RADIUS := 46.0
const SPECIMEN_RADIUS := 10.0

var _world_data: Dictionary
var _world_id: String = ""
var _player: Node2D
var _specimens: Array = []  # [{ "id": String, "node": Node2D, "collected": bool }]

var _status_label: Label
var _prompt_label: Label
var _prompt_timer: Timer


func _ready() -> void:
	_world_data = GameState.get_current_world_data()
	_world_id = _world_data.get("id", "")

	_build_backdrop()
	_build_specimens()
	_build_player()
	_build_ui()
	_update_status()


func _process(delta: float) -> void:
	_move_player(delta)
	_check_pickups()


# ── World ─────────────────────────────────────────────────────────────────────

func _build_backdrop() -> void:
	var ground := Node2D.new()
	ground.name = "Ground"
	var base_color := _color_for_type(_world_data.get("type", "temperate"))
	ground.draw.connect(func():
		ground.draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), base_color)
		var grid_color := base_color.lightened(0.08)
		var step := 140.0
		var x := 0.0
		while x <= WORLD_SIZE.x:
			ground.draw_line(Vector2(x, 0.0), Vector2(x, WORLD_SIZE.y), grid_color, 1.0)
			x += step
		var y := 0.0
		while y <= WORLD_SIZE.y:
			ground.draw_line(Vector2(0.0, y), Vector2(WORLD_SIZE.x, y), grid_color, 1.0)
			y += step
	)
	add_child(ground)
	ground.queue_redraw()


func _color_for_type(world_type: String) -> Color:
	match world_type:
		"ice":
			return Color(0.55, 0.72, 0.85)
		"jungle":
			return Color(0.18, 0.45, 0.22)
		"desert":
			return Color(0.68, 0.5, 0.28)
		"ocean":
			return Color(0.14, 0.32, 0.55)
		_:
			return Color(0.62, 0.5, 0.28)  # temperate


# ── Specimens ─────────────────────────────────────────────────────────────────

func _build_specimens() -> void:
	var ids: Array = _world_data.get("specimens", [])
	for specimen_id in ids:
		if _already_collected(specimen_id):
			continue
		var node := Node2D.new()
		node.name = "Specimen_%s" % specimen_id
		node.position = Vector2(
			randf_range(EDGE_MARGIN, WORLD_SIZE.x - EDGE_MARGIN),
			randf_range(EDGE_MARGIN, WORLD_SIZE.y - EDGE_MARGIN),
		)
		node.draw.connect(func():
			node.draw_circle(Vector2.ZERO, SPECIMEN_RADIUS, Color(1.0, 0.85, 0.3))
			node.draw_circle(Vector2.ZERO, SPECIMEN_RADIUS, Color(1.0, 1.0, 1.0, 0.6), false, 2.0)
			var font := ThemeDB.fallback_font
			node.draw_string(
				font, Vector2(-SPECIMEN_RADIUS, -SPECIMEN_RADIUS - 6.0),
				specimen_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1)
			)
		)
		add_child(node)
		node.queue_redraw()
		_specimens.append({"id": specimen_id, "node": node, "collected": false})


func _already_collected(specimen_id: String) -> bool:
	for s in GameState.specimens:
		if s.get("id", "") == specimen_id and s.get("world_id", "") == _world_id:
			return true
	return false


func _check_pickups() -> void:
	for entry in _specimens:
		if entry["collected"]:
			continue
		var node: Node2D = entry["node"]
		if _player.position.distance_to(node.position) <= COLLECT_RADIUS:
			entry["collected"] = true
			GameState.add_specimen(entry["id"], _world_id)
			node.queue_free()
			_show_prompt("Collected: %s" % entry["id"])
			_update_status()
			SaveLoad.save_game()


# ── Player ────────────────────────────────────────────────────────────────────

func _build_player() -> void:
	_player = Node2D.new()
	_player.name = "Player"
	_player.position = WORLD_SIZE / 2.0
	_player.draw.connect(func():
		_player.draw_circle(Vector2.ZERO, PLAYER_RADIUS, Color(0.9, 0.95, 1.0))
		_player.draw_circle(Vector2.ZERO, PLAYER_RADIUS, Color(0.2, 0.6, 1.0), false, 3.0)
	)
	add_child(_player)
	_player.queue_redraw()

	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	_player.add_child(camera)
	camera.make_current()


func _move_player(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		return
	_player.position += dir * PLAYER_SPEED * delta
	_player.position.x = clampf(_player.position.x, PLAYER_RADIUS, WORLD_SIZE.x - PLAYER_RADIUS)
	_player.position.y = clampf(_player.position.y, PLAYER_RADIUS, WORLD_SIZE.y - PLAYER_RADIUS)


# ── UI ────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "UI"
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	var top_panel := PanelContainer.new()
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_panel.position = Vector2(16.0, 16.0)
	top_panel.size = Vector2(420.0, 96.0)
	root.add_child(top_panel)

	var vbox := VBoxContainer.new()
	top_panel.add_child(vbox)

	_status_label = Label.new()
	vbox.add_child(_status_label)

	var hint := Label.new()
	hint.text = "Arrow keys to walk. Approach glowing specimens to collect."
	hint.modulate = Color(1, 1, 1, 0.7)
	vbox.add_child(hint)

	_prompt_label = Label.new()
	_prompt_label.modulate = Color(0.6, 1.0, 0.6)
	_prompt_label.visible = false
	vbox.add_child(_prompt_label)

	_prompt_timer = Timer.new()
	_prompt_timer.one_shot = true
	_prompt_timer.wait_time = 2.5
	_prompt_timer.timeout.connect(func(): _prompt_label.visible = false)
	add_child(_prompt_timer)

	var return_button := Button.new()
	return_button.text = "Return to Ship"
	return_button.mouse_filter = Control.MOUSE_FILTER_STOP
	return_button.size = Vector2(160.0, 36.0)
	return_button.position = Vector2(1280.0 - 16.0 - 160.0, 16.0)
	return_button.pressed.connect(_on_return_pressed)
	root.add_child(return_button)


func _update_status() -> void:
	var total: int = _world_data.get("specimens", []).size()
	var collected := 0
	for specimen_id in _world_data.get("specimens", []):
		if _already_collected(specimen_id):
			collected += 1
	_status_label.text = "%s — Specimens: %d / %d" % [
		_world_data.get("name", "Unknown"), collected, total
	]


func _show_prompt(text: String) -> void:
	_prompt_label.text = text
	_prompt_label.visible = true
	_prompt_timer.start()


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/travel/travel_screen.tscn")
