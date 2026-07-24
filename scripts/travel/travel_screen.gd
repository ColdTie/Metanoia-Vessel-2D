extends Control

# Travel Screen — the player's main navigation hub.
# All UI is built programmatically so the .tscn stays trivially simple.
# Three parallax star layers scroll right-to-left at different speeds.

const STAR_SPEEDS: Array = [12.0, 28.0, 55.0]
const STAR_COUNTS: Array = [120, 70, 35]
const STAR_SPAN_W: float = 2560.0   # double viewport width for seamless wrap

var _star_layers: Array = []
var _star_root: Node2D

# UI node refs
var _location_label: Label
var _fuel_label: Label
var _passives_label: Label
var _dest_list: VBoxContainer
var _world_name_label: Label
var _world_desc_label: RichTextLabel
var _depart_button: Button
var _settle_button: Button
var _choice_box: VBoxContainer

var _selected_world_id: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_star_root()
	_build_ui()
	_build_star_field()
	_refresh_status()
	_populate_destinations()
	GameState.world_changed.connect(_on_world_changed)
	# Restore save on startup
	if SaveLoad.has_save():
		SaveLoad.load_game()
		_refresh_status()
		_populate_destinations()


func _process(delta: float) -> void:
	_scroll_stars(delta)


# ── Background ────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.07, 1.0)
	add_child(bg)


func _build_star_root() -> void:
	_star_root = Node2D.new()
	_star_root.name = "StarRoot"
	add_child(_star_root)


func _build_star_field() -> void:
	for i in 3:
		var layer := Node2D.new()
		layer.name = "StarLayer%d" % i
		_star_root.add_child(layer)
		_star_layers.append(layer)
		for _j in STAR_COUNTS[i]:
			var star := ColorRect.new()
			# Farther layers = smaller, dimmer
			var sz: float = 1.0 + (2 - i) * 0.7
			star.size = Vector2(sz, sz)
			var v: float = 0.35 + randf() * 0.65
			star.color = Color(v, v, v + randf() * 0.08, 1.0)
			star.position = Vector2(randf() * STAR_SPAN_W, randf() * 720.0)
			layer.add_child(star)


func _scroll_stars(delta: float) -> void:
	for i in _star_layers.size():
		var layer: Node2D = _star_layers[i]
		layer.position.x -= STAR_SPEEDS[i] * delta
		if layer.position.x <= -1280.0:
			layer.position.x = 0.0


# ── UI Layout ─────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "UI"
	add_child(canvas)

	var root := Control.new()
	root.name = "UIRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	_build_left_panel(root)
	_build_right_panel(root)


func _build_left_panel(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.name = "LeftPanel"
	panel.set_anchor(SIDE_LEFT,   0.0)
	panel.set_anchor(SIDE_TOP,    0.0)
	panel.set_anchor(SIDE_RIGHT,  0.0)
	panel.set_anchor(SIDE_BOTTOM, 1.0)
	panel.set_offset(SIDE_LEFT,   16.0)
	panel.set_offset(SIDE_TOP,    16.0)
	panel.set_offset(SIDE_RIGHT,  300.0)
	panel.set_offset(SIDE_BOTTOM, -16.0)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "TRAVEL CHART"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_location_label = _make_label("Location: ...")
	_location_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_location_label)

	_fuel_label = _make_label("Fuel: ...")
	vbox.add_child(_fuel_label)

	_passives_label = _make_label("Passives: 0 / 10")
	vbox.add_child(_passives_label)
	vbox.add_child(HSeparator.new())

	var dest_title := Label.new()
	dest_title.text = "DESTINATIONS"
	dest_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(dest_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_dest_list = VBoxContainer.new()
	_dest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dest_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_dest_list)


func _build_right_panel(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.name = "RightPanel"
	panel.set_anchor(SIDE_LEFT,   0.0)
	panel.set_anchor(SIDE_TOP,    0.0)
	panel.set_anchor(SIDE_RIGHT,  1.0)
	panel.set_anchor(SIDE_BOTTOM, 1.0)
	panel.set_offset(SIDE_LEFT,   316.0)
	panel.set_offset(SIDE_TOP,    16.0)
	panel.set_offset(SIDE_RIGHT,  -16.0)
	panel.set_offset(SIDE_BOTTOM, -16.0)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	_world_name_label = Label.new()
	_world_name_label.text = "Select a destination"
	_world_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_world_name_label)
	vbox.add_child(HSeparator.new())

	_world_desc_label = RichTextLabel.new()
	_world_desc_label.bbcode_enabled = true
	_world_desc_label.fit_content = false
	_world_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_world_desc_label.text = "Choose a world from the chart to see its description."
	vbox.add_child(_world_desc_label)
	vbox.add_child(HSeparator.new())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	_depart_button = Button.new()
	_depart_button.text = "Depart"
	_depart_button.disabled = true
	_depart_button.custom_minimum_size = Vector2(160.0, 40.0)
	_depart_button.pressed.connect(_on_depart_pressed)
	btn_row.add_child(_depart_button)

	_settle_button = Button.new()
	_settle_button.text = "Found Vessel"
	_settle_button.visible = false
	_settle_button.custom_minimum_size = Vector2(160.0, 40.0)
	_settle_button.pressed.connect(_on_settle_pressed)
	btn_row.add_child(_settle_button)

	_choice_box = VBoxContainer.new()
	_choice_box.visible = false
	_choice_box.add_theme_constant_override("separation", 6)
	vbox.add_child(_choice_box)


func _make_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	return lbl


# ── Logic ─────────────────────────────────────────────────────────────────────

func _refresh_status() -> void:
	_location_label.text = "Location:\n" + GameState.current_world
	_fuel_label.text = "Fuel: %d / %d" % [GameState.fuel, GameState.max_fuel]
	_passives_label.text = "Passives: %d / %d" % [
		GameState.passives.size(), GameState.MAX_PASSIVES
	]


func _populate_destinations() -> void:
	for child in _dest_list.get_children():
		child.queue_free()

	for world in GameState.world_catalog:
		var btn := Button.new()
		var settled_tag: String = " [V]" if world.get("settled", false) else ""
		var dist: int = world.get("distance", 0)
		var cost_tag: String = " (%d)" % dist if dist > 0 else " (start)"
		var is_current: bool = world["name"] == GameState.current_world
		btn.text = ("> " if is_current else "") + world["name"] + settled_tag + cost_tag
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.disabled = is_current
		var wid: String = world["id"]
		btn.pressed.connect(func(): _select_world(wid))
		_dest_list.add_child(btn)


func _select_world(world_id: String) -> void:
	_selected_world_id = world_id
	var world := GameState.get_world_by_id(world_id)
	if world.is_empty():
		return

	_world_name_label.text = world["name"]
	_world_desc_label.text = world.get("description", "")

	var cost: int = world.get("distance", 0)
	var is_current: bool = world["name"] == GameState.current_world
	var can_afford: bool = GameState.fuel >= cost

	if is_current:
		_depart_button.disabled = true
		_depart_button.text = "You are here"
	elif not can_afford:
		_depart_button.disabled = true
		_depart_button.text = "Need %d fuel" % cost
	else:
		_depart_button.disabled = false
		_depart_button.text = "Depart  (%d fuel)" % cost

	_settle_button.visible = is_current and not world.get("settled", false)


func _on_depart_pressed() -> void:
	if _selected_world_id.is_empty():
		return
	if GameState.travel_to_world(_selected_world_id):
		_refresh_status()
		_populate_destinations()
		var world := GameState.get_world_by_id(_selected_world_id)
		_world_name_label.text = world.get("name", "")
		_world_desc_label.text = world.get("description", "") \
			+ "\n\n[color=#aaaaaa][i]Exploration coming soon...[/i][/color]"
		_depart_button.disabled = true
		_depart_button.text = "You are here"
		_settle_button.visible = not world.get("settled", false)
	else:
		_world_desc_label.text = \
			GameState.get_world_by_id(_selected_world_id).get("description", "") \
			+ "\n\n[color=red]Not enough fuel to depart.[/color]"


func _on_settle_pressed() -> void:
	var world := GameState.get_world_by_id(_selected_world_id)
	if world.is_empty() or world["name"] != GameState.current_world:
		return
	if world.get("settled", false):
		return

	_settle_button.visible = false

	if GameState.passives.is_empty():
		# First settlement ever: founding passive is automatic, not chosen.
		_finalize_settle(world, {
			"id": "founding_bonus",
			"name": "Founding Bonus",
			"desc": "The act of founding grants clarity. +5 max fuel.",
			"source": world["name"],
		})
		GameState.max_fuel += 5
		GameState.refuel(5)
	else:
		_show_passive_choices(world)


func _show_passive_choices(world: Dictionary) -> void:
	var choices: Array = GameState.get_passive_choices(3)
	if choices.is_empty():
		_finalize_settle(world, {})
		return

	_world_name_label.text = "Choose a Passive"
	_world_desc_label.text = "Founding " + world["name"] + " grants a passive. Choose one:"

	for child in _dest_list.get_children():
		if child is Button:
			child.disabled = true

	for child in _choice_box.get_children():
		child.queue_free()
	_choice_box.visible = true

	for choice in choices:
		var btn := Button.new()
		btn.text = choice["name"] + "\n" + choice["desc"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(): _on_passive_chosen(world, choice))
		_choice_box.add_child(btn)


func _on_passive_chosen(world: Dictionary, passive: Dictionary) -> void:
	for child in _choice_box.get_children():
		child.queue_free()
	_choice_box.visible = false
	_finalize_settle(world, passive)


func _finalize_settle(world: Dictionary, passive: Dictionary) -> void:
	world["settled"] = true
	world["vessel_name"] = "Vessel of " + world["name"]

	if not passive.is_empty():
		var granted := passive.duplicate()
		granted["source"] = world["name"]
		GameState.add_passive(granted)

	_populate_destinations()
	_refresh_status()

	_world_name_label.text = world["vessel_name"]

	var passive_note: String
	if passive.is_empty():
		passive_note = "[color=#aaffaa]No new passives remain to grant.[/color]"
	else:
		passive_note = "[color=#aaffaa]Passive gained: [b]%s[/b] — %s[/color]" \
			% [passive["name"], passive["desc"]]

	_world_desc_label.text = \
		"You have founded [b]" + world["vessel_name"] + "[/b].\n\n" \
		+ world.get("description", "") \
		+ "\n\n" + passive_note

	SaveLoad.save_game()


func _on_world_changed(_new_world: String) -> void:
	_refresh_status()
