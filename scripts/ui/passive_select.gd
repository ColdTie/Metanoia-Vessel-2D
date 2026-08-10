extends Control

# Choose-1-of-3 passive reward popup. Instanced on top of the current
# screen's UI canvas; caller provides the 3 drawn passives via setup()
# and listens for passive_chosen to know which one was picked.

signal passive_chosen(passive_id: String)

var _draws: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_backdrop()


func setup(draws: Array) -> void:
	_draws = draws
	_build_panel()


func _build_backdrop() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.65)
	add_child(dim)


func _build_panel() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460.0, 0.0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var hint := Label.new()
	hint.text = "Founding this Vessel earns a lasting bonus. Pick one."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)
	vbox.add_child(HSeparator.new())

	for draw in _draws:
		var btn := Button.new()
		btn.text = "%s\n%s" % [draw["name"], draw["desc"]]
		btn.custom_minimum_size = Vector2(0.0, 56.0)
		var passive_id: String = draw["id"]
		btn.pressed.connect(func(): _on_choice(passive_id))
		vbox.add_child(btn)


func _on_choice(passive_id: String) -> void:
	passive_chosen.emit(passive_id)
	queue_free()
