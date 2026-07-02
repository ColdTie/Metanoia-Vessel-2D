extends Control
class_name PassiveSelectDialog

# Choose-1-of-3 settling reward popup. Built in code, no .tscn, matching
# travel_screen.gd's pattern. Caller: instantiate, call setup(options),
# add as a child, then connect the `chosen` signal.

signal chosen(passive: Dictionary)

var _options: Array = []


func setup(options: Array) -> void:
	_options = options
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_backdrop()
	_build_panel()


func _build_backdrop() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(backdrop)


func _build_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -220.0)
	panel.set_offset(SIDE_TOP,    -150.0)
	panel.set_offset(SIDE_RIGHT,  220.0)
	panel.set_offset(SIDE_BOTTOM, 150.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for option in _options:
		vbox.add_child(_make_option_button(option))


func _make_option_button(option: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = "%s\n%s" % [option.get("name", ""), option.get("desc", "")]
	btn.custom_minimum_size = Vector2(0.0, 48.0)
	btn.pressed.connect(func(): _on_option_pressed(option))
	return btn


func _on_option_pressed(option: Dictionary) -> void:
	chosen.emit(option)
	queue_free()
