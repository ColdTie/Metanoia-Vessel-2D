extends Control

# Choose-1-of-3 passive reward dialog. Instantiated by travel_screen.gd on
# settle; caller must add this as a child then call setup(choices).

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
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -280.0)
	panel.set_offset(SIDE_TOP,    -170.0)
	panel.set_offset(SIDE_RIGHT,  280.0)
	panel.set_offset(SIDE_BOTTOM, 170.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "A new passive stirs. Choose one:"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in _choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		vbox.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
