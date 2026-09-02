extends Control

# Modal choose-1-of-3 popup shown when founding a Vessel.
# Caller sets `choices` before adding this to the tree, then listens for
# `passive_chosen`. The popup frees itself once a choice is made.

signal passive_chosen(passive: Dictionary)

var choices: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Founding Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for choice in choices:
		vbox.add_child(_build_choice_entry(choice))


func _build_choice_entry(choice: Dictionary) -> Control:
	var entry := PanelContainer.new()

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	entry.add_child(inner)

	var name_label := Label.new()
	name_label.text = choice.get("name", "")
	inner.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = choice.get("desc", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(desc_label)

	var btn := Button.new()
	btn.text = "Choose"
	btn.pressed.connect(func():
		passive_chosen.emit(choice)
		queue_free()
	)
	inner.add_child(btn)

	return entry
