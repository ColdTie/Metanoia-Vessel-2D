extends Control

# Choose-1-of-3 passive reward, shown after founding a Vessel.
# Instantiate, call setup(choices), then connect to `passive_chosen`.
# UI is built in code to match the rest of the project's screens.

signal passive_chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dimmer)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -240.0)
	panel.set_offset(SIDE_RIGHT,   240.0)
	panel.set_offset(SIDE_TOP,    -160.0)
	panel.set_offset(SIDE_BOTTOM,  160.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice["name"], choice["desc"]]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		vbox.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
