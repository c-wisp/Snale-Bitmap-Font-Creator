extends Timer

@onready var Open_Dialog = owner.get_node("OpenDialog")
@onready var Font_Exporter = owner.get_node("Font Exporter")
@onready var Char_Arrangement = %"CharArrangement"

signal autosaved_font(path : String)

func _ready():
	var callable = Callable(self,"change_detected")
	%"FontName".connect("text_changed",callable)
	%"FontSize".connect("changed",callable)
	%"Line Spacing".connect("changed",callable)
	%"Rows".connect("changed",callable)
	%"Columns".connect("changed",callable)
	%"MarginX".connect("changed",callable)
	%"MarginY".connect("changed",callable)
	Char_Arrangement.connect("text_changed",callable)

func change_detected(new_text):
	if new_text.length() > 0 && owner.current_tex_path != "":
		if time_left > 0:
			stop()
		start()

func remove_oldest_file():
	var dir = DirAccess.open("user://")
	if dir.get_files().size() >= 6:
		while dir.get_files().size() >= 6:
			var oldest_file := ""
			for f in dir.get_files():
				if oldest_file == "":
					oldest_file = f
					continue
				if FileAccess.get_modified_time(f) < FileAccess.get_modified_time(oldest_file):
					oldest_file = f
			dir.remove(oldest_file)

func _on_timeout():
	if Char_Arrangement.text.length() == 0:
		return
	
	#save the font w/ its texture alongside it (making room if needed)
	remove_oldest_file()
	var font = owner.new_font()
	Font_Exporter.export(font,"autosavedFont-"+font.info.face,"user://",false)
	await Font_Exporter.export_complete
	
	remove_oldest_file()
	var dir = DirAccess.open("user://")
	dir.copy(Open_Dialog.current_dir+"/"+owner.current_tex_path,"user://"+owner.current_tex_path)
	emit_signal("autosaved_font","user://autosavedFont-"+font.info.face)
