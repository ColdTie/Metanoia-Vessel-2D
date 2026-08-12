extends Control

# Passive Select — choose-1-of-3 popup shown after founding a Vessel.
# Instantiated and configured by travel_screen.gd; builds its own UI in code.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array, world_name: String) -> void:
	_choices = choices
	_build_ui(world_name)


func _build_ui(world_name: String) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -260.0)
	panel.set_offset(SIDE_TOP,    -160.0)
	panel.set_offset(SIDE_RIGHT,  260.0)
	panel.set_offset(SIDE_BOTTOM, 160.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Vessel Founded at " + world_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Choose one passive to carry forward:"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)
	vbox.add_child(HSeparator.new())

	for choice in _choices:
		var btn := Button.new()
		btn.text = "%s — %s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 48.0)
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		vbox.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
