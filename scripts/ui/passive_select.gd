extends Control

# Choose-1-of-3 passive reward popup. Instantiated as a full-screen overlay;
# builds its own UI in code, matching the rest of the project's scene style.
# Caller connects to `passive_chosen`, then frees the node once handled.

signal passive_chosen(passive: Dictionary)

var _choices: Array = []


func setup(choices: Array, vessel_name: String) -> void:
	_choices = choices
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.0, 0.0, 0.0, 0.72)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "%s is founded.\nChoose a passive:" % vessel_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	for passive in _choices:
		vbox.add_child(_make_choice_button(passive))


func _make_choice_button(passive: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(0.0, 56.0)
	btn.pressed.connect(func(): _on_choice_pressed(passive))
	return btn


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
