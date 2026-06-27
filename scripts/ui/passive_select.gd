extends CanvasLayer

# Modal dialog for choose-1-of-3 passive selection at settling time.
# Call setup(options) before add_child; _ready builds the UI from _options.

signal passive_chosen(passive: Dictionary)

var _options: Array = []


func setup(options: Array) -> void:
	_options = options
	layer = 10  # render above travel screen UI (layer 0)


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.78)
	root.add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -410.0)
	panel.set_offset(SIDE_TOP,    -210.0)
	panel.set_offset(SIDE_RIGHT,   410.0)
	panel.set_offset(SIDE_BOTTOM,  210.0)
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   12)
	margin.add_theme_constant_override("margin_right",  12)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "CHOOSE A FOUNDING GIFT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var subtitle := Label.new()
	subtitle.text = "Settling opens something in you. Choose which insight to carry forward."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	vbox.add_child(HSeparator.new())

	if _options.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No passives available."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_lbl)
		return

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(row)

	for passive in _options:
		_build_card(row, passive)


func _build_card(parent: HBoxContainer, passive: Dictionary) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   8)
	margin.add_theme_constant_override("margin_right",  8)
	margin.add_theme_constant_override("margin_top",    8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	var desc_lbl := Label.new()
	desc_lbl.text = passive.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	vbox.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	var pid: String = passive.get("id", "")
	btn.pressed.connect(func() -> void: _on_choose(pid))
	vbox.add_child(btn)


func _on_choose(passive_id: String) -> void:
	for p: Dictionary in _options:
		if p.get("id", "") == passive_id:
			passive_chosen.emit(p)
			break
	queue_free()
