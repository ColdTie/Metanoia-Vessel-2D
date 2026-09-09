extends Control

# Choose-1-of-3 passive reward popup, shown when a world is settled.
# Built in code (mirrors travel_screen.gd's approach) so the .tscn stays trivial.

signal passive_selected(passive: Dictionary)

var _button_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -220.0
	panel.offset_top = -170.0
	panel.offset_right = 220.0
	panel.offset_bottom = 170.0
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_button_box = VBoxContainer.new()
	_button_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_button_box)


func open(choices: Array) -> void:
	for child in _button_box.get_children():
		child.queue_free()

	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.custom_minimum_size = Vector2(0, 56)
		btn.pressed.connect(_on_choice_pressed.bind(passive))
		_button_box.add_child(btn)

	visible = true


func _on_choice_pressed(passive: Dictionary) -> void:
	visible = false
	passive_selected.emit(passive)
