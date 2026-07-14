extends Control

# Choose-1-of-3 settling reward picker. Hidden until open() is called with
# a list of candidate passives; emits passive_selected and hides itself
# once the player picks one. UI built in code, per project convention.

signal passive_selected(passive: Dictionary)

var _choice_list: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(420.0, 320.0)
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	add_child(panel)
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.set_offset(SIDE_LEFT, -210.0)
	panel.set_offset(SIDE_TOP, -160.0)
	panel.set_offset(SIDE_RIGHT, 210.0)
	panel.set_offset(SIDE_BOTTOM, 160.0)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_choice_list = VBoxContainer.new()
	_choice_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_choice_list.add_theme_constant_override("separation", 8)
	vbox.add_child(_choice_list)


func open(choices: Array) -> void:
	for child in _choice_list.get_children():
		child.queue_free()

	for passive in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [passive.get("name", ""), passive.get("desc", "")]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0.0, 64.0)
		var chosen: Dictionary = passive
		btn.pressed.connect(func(): _on_choice_pressed(chosen))
		_choice_list.add_child(btn)

	visible = true


func _on_choice_pressed(passive: Dictionary) -> void:
	visible = false
	passive_selected.emit(passive)
