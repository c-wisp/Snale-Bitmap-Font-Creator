extends Timer

@onready var Open_Dialog = owner.get_node("OpenDialog")
@onready var Font_Exporter = owner.get_node("Font Exporter")
@onready var Char_Arrangement = %"CharArrangement"

signal autosaved_font(path : String)

func _ready():
	var callable = Callable(self,"change_detected")
	%"FontName".connect("text_changed",callable)
	%"FontSize".connect("value_changed",callable)
	%"Line Spacing".connect("value_changed",callable)
	%"Rows".connect("value_changed",callable)
	%"Columns".connect("value_changed",callable)
	%"MarginX".connect("value_changed",callable)
	%"MarginY".connect("value_changed",callable)
	Char_Arrangement.connect("text_changed",callable)

func change_detected(_value = 0):
	if Char_Arrangement.text.length() > 0 && owner.current_tex_path != "":
		if time_left > 0:
			stop()
		start()

func remove_oldest_file():
	var dir = DirAccess.open("user://")
	var hard_break := 0
	if dir.get_files().size() >= 6:
		while dir.get_files().size() >= 6:
			hard_break += 1
			var oldest_file := ""
			for f in dir.get_files():
				if oldest_file == "":
					oldest_file = f
					continue
				if f.ends_with(".fnt"):
					if f.left(f.find("-")).to_int() < oldest_file.left(oldest_file.find("-")).to_int():
						oldest_file = f
				else: #textures get low priorty for autosave (user should have copies of them)
					oldest_file = f
			dir.remove(oldest_file)
			if hard_break >= 8: #just in case it gets stuck or theres a shite ton of files in there
				break

func _on_timeout():
	if Char_Arrangement.text.length() == 0:
		return
	
	#save the font w/ its texture alongside it (making room if needed)
	remove_oldest_file()
	var font = owner.new_font()
	var time = Time.get_date_string_from_system().replace("-","")+Time.get_time_string_from_system().replace(":","")
	Font_Exporter.export(font,time+"-autosavedFont-"+font.info.face,"user://",false)
	await Font_Exporter.export_complete
	
	remove_oldest_file()
	var dir = DirAccess.open("user://")
	var current_folder = (owner.current_file_path.trim_suffix(owner.current_file_path.substr(owner.current_file_path.rfind("/"))))
	dir.copy(current_folder+"/"+owner.current_tex_path,"user://"+owner.current_tex_path)
	emit_signal("autosaved_font","user://"+time+"-autosavedFont-"+font.info.face)
