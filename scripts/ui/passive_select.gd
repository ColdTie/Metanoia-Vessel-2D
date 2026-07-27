extends Control

# Choose-1-of-3 settle reward popup. Instantiated on top of the current
# screen's UI CanvasLayer; call open(choices) right after adding as a child.

signal passive_chosen(passive: Dictionary)

var _card_root: HBoxContainer


func open(choices: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_card_root = HBoxContainer.new()
	_card_root.add_theme_constant_override("separation", 16)
	vbox.add_child(_card_root)

	for choice in choices:
		_add_card(choice)


func _add_card(passive: Dictionary) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200.0, 160.0)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	var name_label := Label.new()
	name_label.text = passive.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = passive.get("desc", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)

	var btn := Button.new()
	btn.text = "Choose"
	btn.pressed.connect(func(): _on_choice(passive))
	vbox.add_child(btn)

	_card_root.add_child(card)


func _on_choice(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
