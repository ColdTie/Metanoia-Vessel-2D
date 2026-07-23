class_name PassiveSelect
extends CanvasLayer

# Choose-1-of-3 passive reward overlay, shown after founding a Vessel.
# Instance, set `choices` (Array of passive dicts) before adding to the
# tree, then listen for `passive_chosen`.

signal passive_chosen(passive: Dictionary)

var choices: Array = []


func _ready() -> void:
	layer = 10
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760.0, 360.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(row)

	for passive in choices:
		row.add_child(_build_card(passive))


func _build_card(passive: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(220.0, 280.0)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 8)
	card.add_child(cvbox)

	var name_label := Label.new()
	name_label.text = passive.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cvbox.add_child(name_label)
	cvbox.add_child(HSeparator.new())

	var desc_label := RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.text = passive.get("desc", "")
	desc_label.fit_content = false
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cvbox.add_child(desc_label)

	var btn := Button.new()
	btn.text = "Choose"
	btn.pressed.connect(func(): passive_chosen.emit(passive))
	cvbox.add_child(btn)

	return card
