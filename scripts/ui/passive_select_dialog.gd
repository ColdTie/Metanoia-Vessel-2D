extends Control

# Choose-1-of-3 passive reward dialog, shown on settling a world.
# Built entirely in code, matching the rest of the UI in this project.
# Usage: instantiate, call setup(choices), await the `chosen` signal.

signal chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	_build_ui(choices)


func _build_ui(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -220.0)
	panel.set_offset(SIDE_TOP,    -160.0)
	panel.set_offset(SIDE_RIGHT,  220.0)
	panel.set_offset(SIDE_BOTTOM, 160.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive["name"], passive["desc"]]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		btn.pressed.connect(func(): _on_choice_pressed(passive))
		vbox.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	chosen.emit(passive)
