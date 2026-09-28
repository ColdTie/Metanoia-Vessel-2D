extends PopupPanel
class_name PassiveSelectPopup

# Choose-1-of-3 settling reward popup. Built entirely in code, instanced by
# whatever screen triggers a settle reward (currently travel_screen.gd).

signal passive_chosen(passive: Dictionary)


func setup(choices: Array) -> void:
	title = "Choose a Passive"
	size = Vector2(560, 240)
	exclusive = true

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "Your Vessel earns a passive. Choose one:"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(row)

	for passive in choices:
		row.add_child(_build_option(passive))


func _build_option(passive: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 150)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	panel.add_child(inner)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = passive.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Choose"
	btn.pressed.connect(func(): _on_choose(passive))
	inner.add_child(btn)

	return panel


func _on_choose(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	hide()
	queue_free()
