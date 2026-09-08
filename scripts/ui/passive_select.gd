extends Control

# Choose-1-of-3 passive reward popup, shown on settling (after the first
# Vessel, which grants Founding Bonus automatically). Built in code, like
# travel_screen.gd, so the .tscn stays trivial.
#
# Usage: instantiate, add to tree, call open_with(source_world_name),
# then connect to `passive_chosen(passive: Dictionary)`. The popup frees
# itself after a choice is made.

signal passive_chosen(passive: Dictionary)

var _source_world: String = ""


func open_with(source_world: String) -> void:
	_source_world = source_world
	_build_ui()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.6)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(560.0, 280.0)
	panel.position = Vector2(-280.0, -140.0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Passive"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Founding a Vessel at %s. Pick one lasting gift:" % _source_world
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(subtitle)
	vbox.add_child(HSeparator.new())

	var choices: Array = GameState.get_passive_choices(3)
	for entry in choices:
		var choice: Dictionary = entry
		var btn := Button.new()
		btn.text = "%s — %s" % [choice["name"], choice["desc"]]
		btn.custom_minimum_size = Vector2(0.0, 44.0)
		btn.pressed.connect(func(): _on_choice_picked(choice))
		vbox.add_child(btn)


func _on_choice_picked(choice: Dictionary) -> void:
	GameState.add_passive({
		"id": choice["id"],
		"name": choice["name"],
		"desc": choice["desc"],
		"source": _source_world,
	})
	passive_chosen.emit(choice)
	queue_free()
