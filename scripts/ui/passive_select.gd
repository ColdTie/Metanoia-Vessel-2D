extends CanvasLayer

# Choose-1-of-3 passive reward popup, shown after founding a Vessel.
# Instantiated dynamically and populated via show_choices(); emits
# passive_chosen with the picked passive dict, then frees itself.

signal passive_chosen(passive: Dictionary)

var _button_container: VBoxContainer


func _ready() -> void:
	layer = 10

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(overlay)

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
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_button_container = VBoxContainer.new()
	_button_container.add_theme_constant_override("separation", 8)
	vbox.add_child(_button_container)


func show_choices(choices: Array) -> void:
	for child in _button_container.get_children():
		child.queue_free()

	for choice in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice.get("name", ""), choice.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 48.0)
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		_button_container.add_child(btn)


func _on_choice_pressed(choice: Dictionary) -> void:
	passive_chosen.emit(choice)
	queue_free()
