extends Control

# Passive selection modal — displayed after founding a Vessel.
# Caller: PassiveSelect.setup(choices), then connect passive_chosen before adding to tree.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_overlay()


func _build_overlay() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.82)
	add_child(dim)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 28)
	vbox.custom_minimum_size = Vector2(900.0, 0.0)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "CHOOSE YOUR PATH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "One gift travels with you. The others pass on."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	var card_row := HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 20)
	vbox.add_child(card_row)

	for passive in _choices:
		card_row.add_child(_build_card(passive))


func _build_card(passive: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(270.0, 220.0)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	panel.add_child(inner)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "Unknown")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(name_lbl)

	inner.add_child(HSeparator.new())

	var desc_lbl := RichTextLabel.new()
	desc_lbl.bbcode_enabled = true
	desc_lbl.text = passive.get("desc", "")
	desc_lbl.fit_content = false
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0.0, 38.0)
	btn.pressed.connect(func(): _choose(passive))
	inner.add_child(btn)

	return panel


func _choose(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
