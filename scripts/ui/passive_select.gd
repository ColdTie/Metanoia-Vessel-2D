extends Control

# Choose-1-of-3 passive reward panel, shown after settling a world
# (except the very first settlement, which auto-grants Founding Bonus).
# Instantiate, call setup(choices), then listen for passive_chosen.

signal passive_chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 64.0)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		vbox.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
