extends Control

# Choose-1-of-3 passive reward popup. Instantiated and added as a child by
# whatever screen grants the reward (currently travel_screen.gd on settling).
# All UI is built in code, matching the rest of the project's convention.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices
	_build_ui()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560.0, 260.0)
	panel.position = Vector2(-280.0, -130.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	vbox.add_child(row)

	for choice in _choices:
		row.add_child(_build_choice_card(choice))


func _build_choice_card(choice: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(170.0, 170.0)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	card.add_child(inner)

	var name_label := Label.new()
	name_label.text = choice.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = choice.get("desc", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(desc_label)

	var pick_btn := Button.new()
	pick_btn.text = "Choose"
	pick_btn.pressed.connect(func(): _on_choice_picked(choice))
	inner.add_child(pick_btn)

	return card


func _on_choice_picked(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
