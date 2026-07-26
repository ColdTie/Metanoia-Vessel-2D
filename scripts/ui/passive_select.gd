extends Control

# Choose-1-of-3 passive reward picker. Instanced once by TravelScreen and
# reused for every settlement after the first. Hidden until open() is called.

signal passive_chosen(passive: Dictionary)

var _card_row: HBoxContainer
var _choices: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.0, 0.0, 0.02, 0.75)
	add_child(scrim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(780.0, 260.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_card_row = HBoxContainer.new()
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_row.add_theme_constant_override("separation", 16)
	_card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_card_row)


func open(choices: Array) -> void:
	_choices = choices
	for child in _card_row.get_children():
		child.queue_free()

	for passive in _choices:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(230.0, 180.0)

		var card_vbox := VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 8)
		card.add_child(card_vbox)

		var name_label := Label.new()
		name_label.text = passive.get("name", "")
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_vbox.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = passive.get("desc", "")
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_vbox.add_child(desc_label)

		var pick_btn := Button.new()
		pick_btn.text = "Choose"
		pick_btn.pressed.connect(_on_pick_pressed.bind(passive))
		card_vbox.add_child(pick_btn)

		_card_row.add_child(card)

	visible = true


func _on_pick_pressed(passive: Dictionary) -> void:
	visible = false
	passive_chosen.emit(passive)
