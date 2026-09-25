extends Control

# Choose-1-of-3 passive reward overlay, shown after founding a Vessel.
# Instantiated dynamically and added as a child of the caller's UI layer;
# frees itself once a choice is made. All UI built in code (see travel_screen.gd).

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in _choices:
		vbox.add_child(_make_choice_button(choice))


func _make_choice_button(choice: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
	btn.custom_minimum_size = Vector2(0.0, 56.0)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.pressed.connect(func(): _on_choice_pressed(choice))
	return btn


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
