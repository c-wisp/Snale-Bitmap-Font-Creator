extends TextEdit

var file_valid_name := "Unnamed Font Face"

var banned_symbols := ["/","\\","<",">",":",'"',"|","?","*","%","\n"]

var reserved_names := ["CON", "PRN", "AUX", "NUL",
"COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
"LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"]

func _on_text_changed():
	file_valid_name = "Untitled Font" #just in case something happens
	if text.count(" ") == text.length():
		return
	if text.to_upper() in reserved_names:
		return
	
	for s in banned_symbols:
		file_valid_name = text.replace(s,"")
	set_line(0,file_valid_name)
	if file_valid_name.ends_with(" ") || file_valid_name.ends_with("."):
		file_valid_name = file_valid_name.left(file_valid_name.length()-1)+"_"
