extends VBoxContainer
#holds the data for easy access by parent nodes

var symbol := ""
var char_size := Vector2.ZERO
var advance := 0
signal changed()

func connect_to_autosave():
	if get_parent().get_owner() != null:
		var Autosave_Timer = get_parent().get_owner().get_node("AutosaveTimer")
		if Autosave_Timer == null:
			return
		connect("changed",Callable(Autosave_Timer,"change_detected"))

func _on_line_edit_text_changed(new_text):
	symbol = new_text
	emit_signal("changed")

func _on_size_x_value_changed(value):
	char_size.x = value
	emit_signal("changed")

func _on_size_y_value_changed(value):
	char_size.y = value
	emit_signal("changed")

func _on_advance_x_value_changed(value):
	advance = value
	emit_signal("changed")

func _on_button_pressed(): #delete button
	if get_parent() != null:
		get_parent().remove_child(self)
		queue_free()
