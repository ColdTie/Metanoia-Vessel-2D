extends CanvasLayer

# Choose-1-of-3 passive reward popup.
# Instantiate, add as a child, then call open(choices) with up to 3
# passive dicts ({id, name, desc}). Emits passive_chosen when the player
# picks one, then frees itself.

signal passive_chosen(passive: Dictionary)

var _button_box: VBoxContainer


func _ready() -> void:
	layer = 10
	_build_ui()


func open(choices: Array) -> void:
	for child in _button_box.get_children():
		child.queue_free()
	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.custom_minimum_size = Vector2(360.0, 64.0)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_choice_pressed.bind(passive))
		_button_box.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(400.0, 0.0)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_button_box = VBoxContainer.new()
	_button_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_button_box)
