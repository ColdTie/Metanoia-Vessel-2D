extends Control

# Choose-1-of-3 settling reward popup. All UI built in code, per project
# convention. Instantiate, call setup(choices), then await passive_chosen.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices
	_build_ui()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -260.0)
	panel.set_offset(SIDE_TOP,    -190.0)
	panel.set_offset(SIDE_RIGHT,   260.0)
	panel.set_offset(SIDE_BOTTOM,  190.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for i in _choices.size():
		var choice: Dictionary = _choices[i]
		var btn := Button.new()
		btn.text = choice.get("name", "") + "\n" + choice.get("desc", "")
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		btn.pressed.connect(_on_choice_pressed.bind(i))
		vbox.add_child(btn)


func _on_choice_pressed(index: int) -> void:
	var chosen: Dictionary = _choices[index]
	passive_chosen.emit(chosen)
	queue_free()
