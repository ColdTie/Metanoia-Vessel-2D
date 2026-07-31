extends Control

# Passive Select — choose-1-of-3 popup shown after settling (after the first
# Vessel, which always grants Founding Bonus automatically). Built in code;
# instanced as a full-rect overlay child of whatever screen triggers it.

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
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -280.0)
	panel.set_offset(SIDE_RIGHT,  280.0)
	panel.set_offset(SIDE_TOP,    -140.0)
	panel.set_offset(SIDE_BOTTOM, 140.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in _choices:
		var btn := Button.new()
		btn.text = "%s — %s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0.0, 48.0)
		var chosen: Dictionary = passive
		btn.pressed.connect(func(): _on_choice_pressed(chosen))
		vbox.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
