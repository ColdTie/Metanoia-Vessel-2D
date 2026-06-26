extends CanvasLayer

# Overlay shown when a player settles a world. Presents 3 passive choices;
# emits passive_chosen when the player picks one.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array) -> void:
	_choices = choices


func _ready() -> void:
	layer = 10
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var outer := VBoxContainer.new()
	outer.set_anchor(SIDE_LEFT, 0.5)
	outer.set_anchor(SIDE_TOP, 0.5)
	outer.set_anchor(SIDE_RIGHT, 0.5)
	outer.set_anchor(SIDE_BOTTOM, 0.5)
	outer.set_offset(SIDE_LEFT, -500.0)
	outer.set_offset(SIDE_TOP, -250.0)
	outer.set_offset(SIDE_RIGHT, 500.0)
	outer.set_offset(SIDE_BOTTOM, 250.0)
	outer.add_theme_constant_override("separation", 12)
	root.add_child(outer)

	var title := Label.new()
	title.text = "CHOOSE YOUR REWARD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Select one passive to carry forward. The others are lost."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(subtitle)

	outer.add_child(HSeparator.new())

	var card_row := HBoxContainer.new()
	card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_row.add_theme_constant_override("separation", 12)
	outer.add_child(card_row)

	for choice in _choices:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_row.add_child(card)

		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 8)
		card.add_child(cvbox)

		var name_lbl := Label.new()
		name_lbl.text = choice["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cvbox.add_child(name_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = choice["desc"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cvbox.add_child(desc_lbl)

		var choose_btn := Button.new()
		choose_btn.text = "Choose"
		choose_btn.custom_minimum_size = Vector2(0.0, 36.0)
		var p := choice
		choose_btn.pressed.connect(func(): _on_chosen(p))
		cvbox.add_child(choose_btn)


func _on_chosen(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
