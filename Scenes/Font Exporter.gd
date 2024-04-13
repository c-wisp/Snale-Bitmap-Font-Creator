extends Node
#exports fonts to a file

@onready var Export_Dialog = %"ExportDialog"
@onready var Export_Panel = %"ExportPanel"
@onready var Export_Prog = Export_Panel.get_child(1)

const DEFAULT_PATH := "C:/Users/steve/Desktop"
const INFO := 'info face="%s" size=%s bold=%s italic=%s charset="%s" unicode=%s stretchH=%s smooth=%s aa=%s padding=%s spacing=%s outline=%s'
const COMMON := 'common lineHeight=%s base=%s scaleW=%s scaleH=%s pages=%s packed=%s alphaChnl=%s redChnl=%s greenChnl=%s blueChnl=%s'
const PAGE := 'page id=%s file="%s" rows=%s columns=%s marginX=%s marginY=%s'
const PAGE_ALT := 'page id=%s file="%s"'
const CHAR := 'char    id=%s    x=%s    y=%s    width=%s    height=%s    xoffset=%s    yoffset=%s    xadvance=%s    page=%s    chnl=%s'
const KERNING := "kerning  first=%s  second=%s  amount=%s"

var length = 0.0
var progress = 0.0
signal fake_delay_ended()
signal export_complete()

func export(fnt, filename := "", where := DEFAULT_PATH, show_panel := true): #'fnt' is an image_font (Main.gd)
	if filename == "":
		filename = fnt.info.face
	if !filename.ends_with(".fnt"):
		filename += ".fnt"
	
	Export_Panel.get_child(0).text = 'Exporting "%s"' % filename
	Export_Panel.visible = show_panel
	length = 4.0+fnt.chars_count+fnt.kernings_count
	progress = 0.0
	
	var dir = DirAccess.open(where+"/") #remove duplicate files
	if dir.file_exists(filename):
		dir.remove(filename)
		await get_tree().physics_frame
	
	var file = FileAccess.open(where+"/"+filename, FileAccess.WRITE)
	
	#font_info
	var file_info := [fnt.info.face, fnt.info.size, fnt.info.bold, fnt.info.italic, fnt.info.charset]
	file_info.append_array([fnt.info.unicode, fnt.info.stretchH, fnt.info.smooth, fnt.info.aa])
	file_info.append_array([fnt.info.padding, fnt.info.spacing, fnt.info.outline])
	var file_info_str = (JSON.stringify(INFO % file_info)).replace("\\n","").replace("\\","")
	file_info_str = file_info_str.replace(", ", ",").replace("(","").replace(")","")
	file.store_line(file_info_str.lstrip('"').rstrip('"'))
	fake_delay()
	await fake_delay_ended
	
	#font_common
	var file_common := [fnt.common.lineHeight, fnt.common.base, fnt.common.scaleW, fnt.common.scaleH, fnt.common.pages, fnt.common.packed]
	file_common.append_array([fnt.common.alphaChnl, fnt.common.redChnl, fnt.common.greenChnl, fnt.common.blueChnl])
	file.store_line((JSON.stringify(COMMON % file_common)).lstrip('"').rstrip('"'))
	fake_delay()
	await fake_delay_ended
	
	#font_page
	for p in fnt.page:
		if p.rows == -1:
			file.store_line((JSON.stringify(PAGE_ALT % [p.id,p.file])).replace("\\","").lstrip('"').trim_suffix('"'))
		else:
			file.store_line((JSON.stringify(PAGE % [p.id,p.file,p.rows,p.columns,p.marginX,p.marginY])).replace("\\","").lstrip('"').trim_suffix('"'))
	fake_delay()
	await fake_delay_ended
	
	#font_char
	file.store_line((JSON.stringify("chars count=%s" % fnt.chars_count)).lstrip('"').rstrip('"'))
	var processed := 0
	for c in fnt.chars:
		var file_char := [c.id, c.x, c.y, c.width, c.height, c.xoffset, c.yoffset, c.xadvance, c.page, c.chnl]
		file.store_line((JSON.stringify(CHAR % file_char)).lstrip('"').rstrip('"'))
		processed += 1
		if fmod(processed,10) == 9:
			fake_delay(1)
			await fake_delay_ended
		else:
			progress += 1
	
	#font_kerning
	if fnt.kernings_count > 0:
		processed = 0
		file.store_line((JSON.stringify("kernings count=%s" % fnt.kernings_count)).lstrip('"').rstrip('"'))
		for k in fnt.kerning:
			file.store_line((JSON.stringify(KERNING % [k.first,k.second,k.amount])).lstrip('"').rstrip('"'))
			processed += 1
			if fmod(processed,10) == 9:
				fake_delay(1)
				await fake_delay_ended
			else:
				progress += 1
	file.close()
	
	Export_Prog.value = 100
	for i in 5:
		await get_tree().physics_frame
	Export_Panel.visible = false
	Export_Prog.value = 0
	
	emit_signal("export_complete")

func fake_delay(amount := 3):
	progress += 1
	Export_Prog.value = progress/length * 100
	for i in amount:
		await get_tree().physics_frame
	emit_signal("fake_delay_ended")

func _on_export_button_button_up():
	Export_Dialog.visible = true

func _on_export_dialog_dir_selected(dir):
	var current_font = owner.new_font()
	var endpath = ""
	endpath = owner.fix_dir_path(dir)
	var dirAcc = DirAccess.open(endpath)
	if dirAcc == null:
		endpath = endpath.left(endpath.rfind("/"))
		dirAcc = DirAccess.open(endpath)
		if dirAcc == null:
			print_debug("Err: Directory not found")
			return
	
	export(current_font, "", endpath)
