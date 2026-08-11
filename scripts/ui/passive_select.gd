extends Control

# Choose-1-of-3 passive reward overlay.
# Instantiate, connect `passive_selected`, then call `open(choices)`.

signal passive_selected(passive: Dictionary)

var _choices: Array = []
var _options_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func open(choices: Array) -> void:
	_choices = choices
	_populate_options()
	visible = true


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 320.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_options_box)


func _populate_options() -> void:
	for child in _options_box.get_children():
		child.queue_free()

	for choice in _choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0.0, 60.0)
		btn.pressed.connect(func(): _on_choice_pressed(choice))
		_options_box.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	visible = false
	passive_selected.emit(choice)
	queue_free()
