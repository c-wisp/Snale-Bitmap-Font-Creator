extends VBoxContainer
#stores kerning pair data, which is parsed at export
var pair := ""
var offset := 0

func update_text(): #used when loading .fnt fils + the text need to be refreshed
	$HBoxContainer/LineEdit.text = pair
	$HBoxContainer2/SpinBox.value = offset

func _on_line_edit_text_changed(new_text):
	pair = new_text

func _on_spin_box_value_changed(value):
	offset = value

func _on_delete_button_button_up():
	if get_parent() != null:
		get_parent().remove_child(self)
		queue_free()
