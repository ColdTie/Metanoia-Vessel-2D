extends Control

# Passive Select Dialog — choose-1-of-3 reward shown when founding a Vessel.
# Instantiated on demand by travel_screen.gd; frees itself after a choice.

signal passive_chosen(passive: Dictionary)

var _options: Array = []


func setup(options: Array, prompt_text: String = "Choose a passive to carry forward:") -> void:
	_options = options
	_build_ui(prompt_text)


func _build_ui(prompt_text: String) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_top = -190.0
	panel.offset_right = 260.0
	panel.offset_bottom = 190.0
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = prompt_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	if _options.is_empty():
		var none_label := Label.new()
		none_label.text = "No new passives available right now."
		none_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(none_label)
		return

	for option in _options:
		var btn := Button.new()
		btn.text = "%s\n%s" % [option.get("name", ""), option.get("desc", "")]
		btn.custom_minimum_size = Vector2(0, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(): _on_choice(option))
		vbox.add_child(btn)


func _on_choice(option: Dictionary) -> void:
	passive_chosen.emit(option)
	queue_free()
