extends Control

# Choose-1-of-3 passive reward popup, shown after settling a world past the
# first. Built in code, same pattern as travel_screen.gd. Caller instances
# this, calls setup(choices), and listens for passive_chosen.

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
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_right = 260.0
	panel.offset_top = -180.0
	panel.offset_bottom = 180.0
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
		btn.text = "%s\n\n%s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 80.0)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_choice_pressed.bind(i))
		vbox.add_child(btn)


func _on_choice_pressed(index: int) -> void:
	if index < 0 or index >= _choices.size():
		return
	passive_chosen.emit(_choices[index])
	queue_free()
