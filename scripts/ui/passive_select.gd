extends CanvasLayer

# Choose-1-of-3 passive reward popup, shown after settling any world past
# the first. All UI is built in code, per project convention.

signal passive_chosen(passive: Dictionary)

var _card_row: HBoxContainer


func open(choices: Array) -> void:
	layer = 100
	_build_ui(choices)


func _build_ui(choices: Array) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 260.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_card_row = HBoxContainer.new()
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_row.add_theme_constant_override("separation", 16)
	_card_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_card_row)

	for passive in choices:
		_card_row.add_child(_make_card(passive))


func _make_card(passive: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(160.0, 180.0)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	card.add_child(col)

	var name_label := Label.new()
	name_label.text = passive.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = passive.get("desc", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(desc_label)

	var btn := Button.new()
	btn.text = "Choose"
	btn.pressed.connect(func(): _on_choice(passive))
	col.add_child(btn)

	return card


func _on_choice(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
