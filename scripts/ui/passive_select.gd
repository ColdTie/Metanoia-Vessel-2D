extends Control

# Choose-1-of-3 passive reward overlay, shown when founding a Vessel.
# Built in code to match the travel screen's UI pattern.

signal chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -280.0)
	panel.set_offset(SIDE_RIGHT,   280.0)
	panel.set_offset(SIDE_TOP,    -180.0)
	panel.set_offset(SIDE_BOTTOM,  180.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Founding Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in choices:
		var btn := Button.new()
		btn.text = "%s — %s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 56)
		btn.pressed.connect(func(): _on_choice_pressed(passive))
		vbox.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	chosen.emit(passive)
	queue_free()
