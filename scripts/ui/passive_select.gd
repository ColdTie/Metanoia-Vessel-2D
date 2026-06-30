extends Control

# Modal overlay shown when founding a Vessel.
# Call show_draw(options) with an Array of passive dicts from GameState.draw_passive_options().
# Emits passive_chosen(passive) when the player picks one, then hides itself.

signal passive_chosen(passive: Dictionary)

const CARD_MIN_SIZE := Vector2(252.0, 200.0)
const PANEL_MIN_W := 860.0
const PANEL_MIN_H := 380.0


func show_draw(options: Array) -> void:
	for child in get_children():
		child.queue_free()
	_build_overlay(options)
	visible = true


func _build_overlay(options: Array) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.72)
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var outer := PanelContainer.new()
	outer.custom_minimum_size = Vector2(PANEL_MIN_W, PANEL_MIN_H)
	center.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	outer.add_child(vbox)

	var title := Label.new()
	title.text = "FOUNDING REWARD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Choose one passive to carry forward."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	vbox.add_child(HSeparator.new())

	var cards_row := HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 12)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(cards_row)

	for opt in options:
		_build_card(cards_row, opt)


func _build_card(parent: HBoxContainer, passive: Dictionary) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_MIN_SIZE
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = passive.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	var desc_lbl := RichTextLabel.new()
	desc_lbl.bbcode_enabled = true
	desc_lbl.fit_content = false
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.text = passive.get("desc", "")
	vbox.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	var p := passive  # capture for closure
	btn.pressed.connect(func(): _on_choose(p))
	vbox.add_child(btn)


func _on_choose(passive: Dictionary) -> void:
	visible = false
	passive_chosen.emit(passive)
