extends Control

# Choose-1-of-3 settling reward dialog. Built entirely in code, same
# convention as travel_screen.gd. Instantiated on top of the travel
# screen's UI and freed once a choice is made.

signal option_chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in choices:
		_build_option_row(vbox, passive)


func _build_option_row(vbox: VBoxContainer, passive: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	vbox.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = passive.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(260.0, 0.0)
	info.add_child(desc_lbl)

	var choose_btn := Button.new()
	choose_btn.text = "Choose"
	choose_btn.pressed.connect(func():
		option_chosen.emit(passive)
		queue_free()
	)
	row.add_child(choose_btn)

	vbox.add_child(HSeparator.new())
