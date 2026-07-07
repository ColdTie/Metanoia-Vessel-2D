extends Control

# Choose-1-of-3 passive reward popup, shown after settling a world.
# Built in code, same pattern as travel_screen.gd. Caller instantiates,
# adds to the tree, then calls setup(options) with 1-3 passive dicts.

signal passive_chosen(passive: Dictionary)

var _options: Array = []


func setup(options: Array) -> void:
	_options = options
	_build_ui()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -320.0)
	panel.set_offset(SIDE_TOP, -180.0)
	panel.set_offset(SIDE_RIGHT, 320.0)
	panel.set_offset(SIDE_BOTTOM, 180.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for option in _options:
		var btn := Button.new()
		btn.text = "%s\n%s" % [option.get("name", ""), option.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 64.0)
		btn.pressed.connect(_choose.bind(option))
		vbox.add_child(btn)


func _choose(option: Dictionary) -> void:
	passive_chosen.emit(option)
	queue_free()
