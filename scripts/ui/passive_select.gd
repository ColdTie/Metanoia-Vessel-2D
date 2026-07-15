extends CanvasLayer

# Choose-1-of-3 passive reward overlay. Instantiated by travel_screen on settle.
# Call open(choices) with up to 3 passive dicts from GameState.get_passive_choices().

signal chosen(passive: Dictionary)

var _choices: Array = []


func open(choices: Array) -> void:
	_choices = choices
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(dim)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -350.0)
	panel.set_offset(SIDE_TOP, -130.0)
	panel.set_offset(SIDE_RIGHT, 350.0)
	panel.set_offset(SIDE_BOTTOM, 130.0)
	root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	vbox.add_child(row)

	for i in _choices.size():
		var choice: Dictionary = _choices[i]
		var btn := Button.new()
		btn.text = choice.get("name", "") + "\n\n" + choice.get("desc", "")
		btn.custom_minimum_size = Vector2(200, 140)
		btn.pressed.connect(_on_choice_pressed.bind(i))
		row.add_child(btn)


func _on_choice_pressed(i: int) -> void:
	if i < 0 or i >= _choices.size():
		return
	chosen.emit(_choices[i])
	queue_free()
