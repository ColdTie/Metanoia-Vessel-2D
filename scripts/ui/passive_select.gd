extends CanvasLayer

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices
	layer = 100
	_build_ui()


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.82)
	root.add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchor_and_offset(SIDE_LEFT,   0.5, -470.0)
	panel.set_anchor_and_offset(SIDE_RIGHT,  0.5,  470.0)
	panel.set_anchor_and_offset(SIDE_TOP,    0.5, -210.0)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5,  210.0)
	root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "CHOOSE A PASSIVE REWARD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "One of these will stay with you for the rest of the voyage."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = Color(0.75, 0.75, 0.75, 1.0)
	vbox.add_child(sub)

	vbox.add_child(HSeparator.new())

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 14)
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	for p in _choices:
		_build_card(hbox, p)


func _build_card(parent: HBoxContainer, p: Dictionary) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(270.0, 0.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = p.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	var desc_lbl := RichTextLabel.new()
	desc_lbl.bbcode_enabled = true
	desc_lbl.fit_content = false
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.text = p.get("desc", "")
	vbox.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	btn.pressed.connect(_on_choose.bind(p))
	vbox.add_child(btn)


func _on_choose(p: Dictionary) -> void:
	passive_chosen.emit(p)
	queue_free()
