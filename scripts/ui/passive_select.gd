extends Control

# Choose-1-of-3 settling reward overlay. Instanced over the Travel Screen,
# built entirely in code. Caller connects to `passive_chosen`, then this
# node frees itself once a choice is made.

signal passive_chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Settling Reward"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in choices:
		vbox.add_child(_build_choice_row(passive))


func _build_choice_row(passive: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label := Label.new()
	name_label.text = passive.get("name", "")
	text_box.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = passive.get("desc", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	text_box.add_child(desc_label)

	row.add_child(text_box)

	var choose_btn := Button.new()
	choose_btn.text = "Choose"
	choose_btn.custom_minimum_size = Vector2(90.0, 36.0)
	choose_btn.pressed.connect(func(): _on_choice_made(passive))
	row.add_child(choose_btn)

	return row


func _on_choice_made(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
