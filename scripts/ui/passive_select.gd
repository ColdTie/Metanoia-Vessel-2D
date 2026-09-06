extends CanvasLayer

# Choose-1-of-3 passive reward popup.
# Instantiate, set `choices` (Array of {id, name, desc}), add to the tree,
# then connect `passive_chosen`. Frees itself once a choice is made.

signal passive_chosen(passive: Dictionary)

var choices: Array = []


func _ready() -> void:
	layer = 10
	_build_ui()


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in choices:
		vbox.add_child(_make_choice_row(passive))


func _make_choice_row(passive: Dictionary) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var btn := Button.new()
	btn.text = passive.get("name", "???")
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	btn.pressed.connect(_choose.bind(passive))
	row.add_child(btn)

	var desc := Label.new()
	desc.text = passive.get("desc", "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(desc)
	row.add_child(HSeparator.new())

	return row


func _choose(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
