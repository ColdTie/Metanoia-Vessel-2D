extends Control
class_name PassiveSelectPanel

# Choose-1-of-3 passive reward panel. Instantiate, add to the tree, then
# call show_choices(). Emits passive_chosen with the picked dict and frees
# itself. Caller is responsible for granting the passive via GameState.

signal passive_chosen(passive: Dictionary)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)


func show_choices(choices: Array) -> void:
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

	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		btn.pressed.connect(_on_choice_pressed.bind(passive))
		vbox.add_child(btn)


func _on_choice_pressed(passive: Dictionary) -> void:
	passive_chosen.emit(passive)
	queue_free()
