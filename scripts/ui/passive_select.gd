extends Control

# Choose-1-of-3 passive reward panel, shown when founding a Vessel.
# Instantiate, call setup(choices, vessel_name), then listen for
# `passive_chosen`. Frees itself once a choice is made.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array, vessel_name: String) -> void:
	_choices = choices
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui(vessel_name)


func _build_ui(vessel_name: String) -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460.0, 320.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Founding " + vessel_name + "\nChoose a passive to carry forward:"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in _choices:
		var c: Dictionary = choice
		var btn := Button.new()
		btn.text = "%s\n%s" % [c.get("name", ""), c.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 64.0)
		btn.pressed.connect(func(): _choose(c))
		vbox.add_child(btn)


func _choose(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
