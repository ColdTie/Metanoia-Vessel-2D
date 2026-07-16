extends Control

# Choose-1-of-3 passive reward overlay, shown on settling a world after the
# first (which grants Founding Bonus automatically). Instanced and added to a
# parent UI root; call setup() with up to 3 passive dicts, then wait for
# passive_chosen. Frees itself once a choice is made.

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
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720.0, 300.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	vbox.add_child(row)

	for passive in _choices:
		row.add_child(_build_card(passive))


func _build_card(passive: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(210.0, 220.0)

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 8)
	card.add_child(card_vbox)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = passive.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_vbox.add_child(desc_lbl)

	var choose_btn := Button.new()
	choose_btn.text = "Choose"
	choose_btn.pressed.connect(func(): _on_choose(passive))
	card_vbox.add_child(choose_btn)

	return card


func _on_choose(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
