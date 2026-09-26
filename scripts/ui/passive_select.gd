extends Control

# Choose-1-of-3 passive reward overlay. Instanced by travel_screen.gd after a
# non-founding settlement; caller calls setup(choices) then listens for
# passive_chosen. Frees itself once a choice is made.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.02, 0.75)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

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

	for choice in _choices:
		vbox.add_child(_build_option(choice))


func setup(choices: Array) -> void:
	_choices = choices


func _build_option(choice: Dictionary) -> Control:
	var btn := Button.new()
	btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(0.0, 56.0)
	btn.pressed.connect(func(): _on_option_pressed(choice))
	return btn


func _on_option_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
