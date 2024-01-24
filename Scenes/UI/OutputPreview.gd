extends TextEdit
#uses the autosave script to load in-progress fonts+display them in-editor

#reminder to change this to the actual font that will be used everywhere
#@onready var BASE_FONT = preload("res://Ref/base font ref.fnt")
@onready var Input_Text = get_parent().get_node("Input Preview")

#func _on_open_dialog_confirmed():
##	add_theme_font_override("font",BASE_FONT)
	#remove_theme_font_override("font")

func _on_open_dialog_file_selected(_path):
#	add_theme_font_override("font",BASE_FONT)
	remove_theme_font_override("font")

func _on_autosave_timer_autosaved_font(path):
	var font = FontFile.new()
	font.load_bitmap_font(path+".fnt")
	add_theme_font_override("font",font)

func _on_input_preview_text_changed():
	text = Input_Text.text
