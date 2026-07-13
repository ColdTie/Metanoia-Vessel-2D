extends Control

# Choose-1-of-3 passive reward popup, shown after settling a world
# (except the first settlement, which auto-grants Founding Bonus).
# UI is built in code, matching the travel screen's pattern.

signal passive_chosen(passive: Dictionary)

var _choices_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -260.0)
	panel.set_offset(SIDE_RIGHT, 260.0)
	panel.set_offset(SIDE_TOP, -170.0)
	panel.set_offset(SIDE_BOTTOM, 170.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Your Vessel grants one lasting gift."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.75, 0.75, 0.75, 1.0)
	vbox.add_child(subtitle)
	vbox.add_child(HSeparator.new())

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_choices_box)


func open(choices: Array) -> void:
	for child in _choices_box.get_children():
		child.queue_free()
	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0.0, 60.0)
		var chosen: Dictionary = passive
		btn.pressed.connect(func(): _on_choice_pressed(chosen))
		_choices_box.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
