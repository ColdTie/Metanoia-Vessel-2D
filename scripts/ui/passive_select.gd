extends Control

# Choose-1-of-3 passive reward popup, shown on settling a Vessel (after the
# first, which grants Founding Bonus automatically). Caller instances this
# scene, calls open(), and receives the chosen passive via the callback.

var _on_chosen: Callable
var _card_list: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(420.0, 320.0)
	panel.position = Vector2(-210.0, -160.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	_card_list = VBoxContainer.new()
	_card_list.add_theme_constant_override("separation", 8)
	vbox.add_child(_card_list)


func open(choices: Array, source_world_name: String, on_chosen: Callable) -> void:
	_on_chosen = on_chosen
	for choice in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [choice["name"], choice["desc"]]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0.0, 60.0)
		btn.pressed.connect(_on_choice_pressed.bind(choice, source_world_name))
		_card_list.add_child(btn)


func _on_choice_pressed(choice: Dictionary, source_world_name: String) -> void:
	var passive := {
		"id": choice["id"],
		"name": choice["name"],
		"desc": choice["desc"],
		"source": source_world_name,
	}
	if _on_chosen.is_valid():
		_on_chosen.call(passive)
	queue_free()
