extends CanvasLayer

# Modal overlay: presents 3 passive choices and emits the player's pick.
# Usage:
#   var sel = PassiveSelectScene.instantiate()
#   sel.setup(choices_array)   # call BEFORE add_child
#   add_child(sel)
#   sel.passive_chosen.connect(func(p): ...)

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.78)
	root.add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT,   0.5)
	panel.set_anchor(SIDE_TOP,    0.5)
	panel.set_anchor(SIDE_RIGHT,  0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT,   -400.0)
	panel.set_offset(SIDE_TOP,    -230.0)
	panel.set_offset(SIDE_RIGHT,   400.0)
	panel.set_offset(SIDE_BOTTOM,  230.0)
	root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Founding Reward"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "One gift from the new world — choose wisely."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = Color(0.75, 0.75, 0.75, 1.0)
	vbox.add_child(sub)

	vbox.add_child(HSeparator.new())

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 10)
	vbox.add_child(cards_row)

	for p in _choices:
		_build_card(cards_row, p)


func _build_card(parent: HBoxContainer, passive: Dictionary) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	var desc_lbl := RichTextLabel.new()
	desc_lbl.bbcode_enabled = true
	desc_lbl.fit_content = false
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(0.0, 90.0)
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.text = passive.get("desc", "")
	vbox.add_child(desc_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	var p := passive.duplicate()
	btn.pressed.connect(_on_passive_chosen.bind(p))
	vbox.add_child(btn)


func _on_passive_chosen(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
