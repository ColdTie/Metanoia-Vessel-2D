extends Control

# Choose-1-of-3 passive reward popup. Instantiate, call setup(choices), add
# to the scene tree, then wait for passive_chosen before freeing the caller's
# reference (the popup frees itself after emitting).

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
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
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
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		var chosen: Dictionary = passive
		btn.pressed.connect(func(): _on_choice_pressed(chosen))
		vbox.add_child(btn)

	# Center the panel manually since PRESET_CENTER only sets anchors.
	panel.set_offset(SIDE_LEFT, -260.0)
	panel.set_offset(SIDE_RIGHT, 260.0)
	panel.set_offset(SIDE_TOP, -160.0)
	panel.set_offset(SIDE_BOTTOM, 160.0)


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
