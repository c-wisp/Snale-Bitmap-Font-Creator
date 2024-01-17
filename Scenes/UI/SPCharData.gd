extends VBoxContainer
#holds the data for easy access by parent nodes

var symbol := ""
var char_size := Vector2.ZERO
var advance := 0

@onready var Text = $"Main/TextEdit"

func _on_text_edit_text_changed():
	symbol = Text.text

func _on_size_x_value_changed(value):
	char_size.x = value

func _on_size_y_value_changed(value):
	char_size.y = value

func _on_advance_x_value_changed(value):
	advance = value

func _on_button_pressed(): #delete button
	if get_parent() != null:
		get_parent().remove_child(self)
		queue_free()
