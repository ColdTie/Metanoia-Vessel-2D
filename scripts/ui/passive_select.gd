extends Control

# Modal choose-1-of-3 passive reward panel.
# Instantiated once by travel_screen.gd; call open(choices) to show it,
# listen for passive_selected to know what the player picked.

signal passive_selected(passive: Dictionary)

var _choices_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func open(choices: Array) -> void:
	for child in _choices_box.get_children():
		child.queue_free()
	for passive in choices:
		var btn := Button.new()
		btn.text = passive.get("name", "")
		btn.tooltip_text = passive.get("desc", "")
		btn.custom_minimum_size = Vector2(360.0, 44.0)
		var chosen: Dictionary = passive
		btn.pressed.connect(func(): _on_choice_pressed(chosen))
		_choices_box.add_child(btn)
	visible = true


func _on_choice_pressed(passive: Dictionary) -> void:
	visible = false
	passive_selected.emit(passive)


func _build_ui() -> void:
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
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var hint := Label.new()
	hint.text = "(hover a choice for its effect)"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)
	vbox.add_child(HSeparator.new())

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_choices_box)
