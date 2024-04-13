extends Node2D
#holds global data & creates fonts

@onready var Exporter = $"Font Exporter"
@onready var Error_Dialog = $"ErrorDialog"
@onready var Open_Dialog = $"OpenDialog"
@onready var Loaded_Texture_Label = $"CanvasLayer/UI/LoadedTexLabel"
@onready var Tex_Display = $"CenterContainer/TextureRect"
@onready var Font_Name = %"FontName"
@onready var Font_Size = %"FontSize"
@onready var Line_Spacing = %"Line Spacing"
@onready var Rows = %"Rows"
@onready var Columns = %"Columns"
@onready var Margin_X = %"MarginX"
@onready var Margin_Y = %"MarginY"
@onready var Char_Arrangement = %"CharArrangement"
@onready var Special_Chars = %"SPC Box"
@onready var Kerning_Pairs = %"KP Box"

@export var char_offset := Vector2.ZERO #how many px the char is shifted by
var current_tex_path := ""
var current_file_path := ""
var char_cache := [] #used for sprites w/ non-grid textures (specifically on .fnt load)
signal ERR_LOAD_FAILED()

#region classes
#NOTICE see https://www.angelcode.com/products/bmfont/doc/file_format.html for deets on what does what
class image_font:
	var info : font_info
	var common : font_common
	var page : Array #contains font_page
	var chars_count : int
	var chars : Array #contains font_char, needs to be renamed to "char" on export (built in function has same name)
	var kernings_count : int
	var kerning : Array

class font_info:
	var face : String
	var size : int
	var bold := 0
	var italic := 0
	var charset := ""
	var unicode := 1
	var stretchH := 100 #stretch height in percent
	var smooth := 0
	var aa := 1 #1 is false for supersampling
	var padding := Vector4.ZERO
	var spacing := Vector2.ONE
	var outline := 0

class font_common:
	var lineHeight : int
	var base : int
	var scaleW : int #texture size
	var scaleH : int
	var pages : int #number of textures
	var packed := 0
	var alphaChnl := 1
	var redChnl := 0
	var greenChnl := 0
	var blueChnl := 0

class font_page:
	var id := 0
	var file : String
	var rows := -1 #custom variable (plus 3 following)
	var columns := -1
	var marginX := -1
	var marginY := -1

class font_char: #create one for every character
	var id : int
	var x : int
	var y : int
	var width : int
	var height : int
	var xoffset : int
	var yoffset : int
	var xadvance : int
	var page := 0
	var chnl := 15

class font_kerning:
	var first : int
	var second : int
	var amount : int
#endregion

func _ready():
	Tex_Display.visible = false

func new_font(): #creates a font file using the data given
	var current_font = image_font.new()
	var current_tex = Tex_Display.texture
	current_font.info = font_info.new()
	current_font.info.face = Font_Name.file_valid_name
	current_font.info.size = roundi(Font_Size.value*Line_Spacing.value-0.1)
	
	current_font.common = font_common.new()
	current_font.common.lineHeight = current_font.info.size
	current_font.common.base = Font_Size.value
	current_font.common.scaleW = roundi(current_tex.get_size().x)
	current_font.common.scaleH = roundi(current_tex.get_size().y)
	current_font.common.pages = 1
	
	current_font.page = [font_page.new()]
	current_font.page[0].file = current_tex_path
	if char_cache.size() == 0:
		current_font.page[0].rows = Rows.value
		current_font.page[0].columns = Columns.value
		current_font.page[0].marginX = Margin_X.value
		current_font.page[0].marginY = Margin_Y.value
	
	var sp_char_adj := {}
	for c in Special_Chars.get_children():
		if c.get_index() <= 1:
			continue
		sp_char_adj[c.symbol] = c
	
	if char_cache.size() > 0:
		current_font.chars = char_cache.duplicate()
		if sp_char_adj.size() > 0:
			for c in char_cache:
				if sp_char_adj.size() == 0:
					break
				if sp_char_adj.has(String.chr(c.id)):
					print_debug("err here")
					var index = sp_char_adj[String.chr(c.id)]
					current_font.chars[c].width = index.char_size.x if index.char_size.x != 0 else current_font.chars[c].width
					current_font.chars[c].height = index.char_size.y if index.char_size.y != 0 else current_font.chars[c].height
					current_font.chars[c].xadvance = index.advance if index.advance != 0 else current_font.chars[c].width
					sp_char_adj.erase(String.chr(c.id))
	else:
		var char_rows := []
		for l in Char_Arrangement.get_line_count():
			char_rows.append(Char_Arrangement.get_line(l))
		
		var zero_found := false
		if char_rows[0] != "":
			var row_column_ct = Vector2(Rows.value,Columns.value)
			var margins = Vector2(Margin_X.value,Margin_Y.value)
			var char_size = Vector2(round((current_tex.get_size()-margins*row_column_ct)/row_column_ct))
			
			for c in row_column_ct.y:
				if char_rows.size() <= c:
					break
				for r in row_column_ct.x:
					if char_rows[c].length() <= r: #autocancel when out of letters
						break
					
					if char_rows[c][r] == "0": #ignore the 0s used as padding
						if zero_found:
							continue
						zero_found = true
					
					var letter = font_char.new()
					letter.id = char_rows[c].unicode_at(int(r))
					
					var letter_pos = (char_size+margins)*Vector2(r,c)+margins/2
					letter.x = letter_pos.x
					letter.y = letter_pos.y
					
					letter.xoffset = char_offset.x
					letter.yoffset = char_offset.y
					if sp_char_adj.keys().has(char_rows[c][r]):
						var index = sp_char_adj[char_rows[c][r]]
						letter.width = index.char_size.x if index.char_size.x != 0 else char_size.x
						letter.height = index.char_size.y if index.char_size.y != 0 else char_size.y
						letter.xadvance = index.advance if index.advance != 0 else char_size.x
						
						#make sure that the symbol is still centered after the size change
						var pos_offset = char_size - index.char_size
						if pos_offset.x != char_size.x:
							letter.x += round(pos_offset.x/2)
						if pos_offset.y != char_size.y:
							letter.y += round(pos_offset.y/2)
					else:
						letter.width = char_size.x
						letter.height = char_size.y
						letter.xadvance = char_size.x
					
					current_font.chars.append(letter)
	
	for k in Kerning_Pairs.get_children():
		if k.get_index() <= 1 || k.pair.length() < 2 || k.offset == 0:
			continue
		if k.pair.begins_with("*"):
			var second = k.pair.unicode_at(k.pair.length()-1)
			for c in current_font.chars:
				var pair = font_kerning.new()
				pair.first = c.id
				pair.second = second
				pair.amount = k.offset
				current_font.kerning.append(pair)
		else:
			var pair = font_kerning.new()
			pair.first = "*".unicode_at(0) if k.pair.begins_with('"*"') else k.pair.unicode_at(0)
			pair.second = k.pair.unicode_at(k.pair.length()-1)
			pair.amount = k.offset
			current_font.kerning.append(pair)
	
	current_font.kernings_count = current_font.kerning.size()
	current_font.chars_count = current_font.chars.size()
	return current_font

func load_font(path : String): #loads .fnt files so they can be edited after export
	var file = FileAccess.open(path,FileAccess.READ)
	var Individual_Char_Adj = $"CanvasLayer/UI/Right Toolbar/VBoxContainer/IndividualCharAdj"
	
	var chardata := []
	var tex_is_grid := false
	char_cache.clear()
	while file.get_position() < file.get_length():
		var data = file.get_line()
		match data.left(data.find(" ")):
			"info":
				Font_Name.text = data.left(data.find(" size")).trim_prefix("info face=").replace('"',"")
				Font_Name._on_text_changed(Font_Name.text) #refresh
			"common":
				var data_array = data.split(" ",false)
				Font_Size.value = data_array[2].to_int()
				Line_Spacing.value = data_array[1].to_int()/Font_Size.value
			"page":
				var tex_path = data.substr(data.find("file=")).trim_prefix('file="')
				var dir = (current_file_path.trim_suffix(current_file_path.substr(current_file_path.rfind("/"))))
				tex_path = dir+"/"+tex_path.substr(0,tex_path.rfind('"'))
				current_tex_path = tex_path.right(-tex_path.rfind("/")-1)
				if !FileAccess.file_exists(tex_path):
					reset()
					Error_Dialog.dialog_text = "A texture has failed to load -- please ensure that all\nrequired textures are in the correct directory."
					Error_Dialog.size = Vector2(410,120)
					Error_Dialog.visible = true
					break
				Tex_Display.texture = ImageTexture.create_from_image(Image.load_from_file(tex_path))
				Tex_Display.visible = true
				Loaded_Texture_Label.text = "Loaded: "+current_tex_path
				%"ExportButton".disabled = false
				
				#check if the page has a grid or not
				#some extra data is tacked on to aid this process (its a pain)
				if data.find("rows=") != -1:
					var extra_data = data.substr(data.find("rows=")).split(" ",false)
					Rows.value = extra_data[0].to_int()
					Columns.value = extra_data[1].to_int()
					Margin_X.value = extra_data[2].to_int()
					Margin_Y.value = extra_data[3].to_int()
					Char_Arrangement.text = ("".rpad(Rows.value,"0")).repeat(Columns.value)
					tex_is_grid = true
				else:
					#lock the rows/columns tick boxes so they dont fuck with the current setup
					for g in get_tree().get_nodes_in_group("SheetData"):
						g.editable = false
			"char":
				#grab all of the data so it can be used later
				var new_char = font_char.new()
				var data_array = data.split(" ",false)
				new_char.id = data_array[1].to_int()
				new_char.x = data_array[2].to_int()
				new_char.y = data_array[3].to_int()
				new_char.width = data_array[4].to_int()
				new_char.height = data_array[5].to_int()
				new_char.xoffset = data_array[6].to_int()
				new_char.yoffset = data_array[7].to_int()
				new_char.xadvance = data_array[8].to_int()
				new_char.page = data_array[9].to_int()
				new_char.chnl = data_array[10].to_int()
				
				if tex_is_grid:
					Char_Arrangement.text[chardata.size()] = String.chr(new_char.id)
					
					var grid_size = Tex_Display.texture.get_size() / Vector2(Rows.value,Columns.value) - Vector2(Margin_X.value,Margin_Y.value)
					if new_char.xadvance != grid_size.x || new_char.width != grid_size.x || new_char.height != grid_size.y:
						var new_sp = Individual_Char_Adj.SPCharData_Base.instantiate()
						Special_Chars.add_child(new_sp)
						new_sp.symbol = String.chr(new_char.id)
						new_sp.advance = new_char.xadvance if new_char.xadvance != grid_size.x else 0
						new_sp.char_size.x = new_char.width if new_char.width != grid_size.x else 0
						new_sp.char_size.y = new_char.height if new_char.height != grid_size.y else 0
						new_sp.update_text()
						new_sp.connect_to_autosave()
				chardata.append(new_char)
			"kerning":
				var data_array = data.split(" ",false)
				var new_pair = Individual_Char_Adj.KerningPair_Base.instantiate()
				Kerning_Pairs.add_child(new_pair)
				new_pair.pair = String.chr(data_array[1].to_int())+String.chr(data_array[2].to_int())
				new_pair.offset = data_array[3].to_int()
				new_pair.update_text()
				new_pair.connect_to_autosave()
	
	#fix the char_arrangement to fit the row/column ct
	#shouldnt really do anything (aside from visuals) if the texture isnt a grid
	var SplitVis = $CenterContainer/TextureRect/SplitVisual
	if tex_is_grid:
		for c in Columns.value:
			Char_Arrangement.text = Char_Arrangement.text.insert(Rows.value*(c+1)+c,"\n")
		var textcache = Char_Arrangement.text.trim_suffix("\n")
		Char_Arrangement.clear()
		Char_Arrangement.text = textcache
		SplitVis.grid_enabled = true
	else:
		char_cache.append_array(chardata)
		SplitVis.grid_enabled = false
		SplitVis.divide_unlimited()
	
	$AutosaveTimer._on_timeout() #call the autosave timer to quicksave + refresh the text

func reset():
	Font_Name.text = ""
	Font_Size.value = 1
	Line_Spacing.value = 1
	Rows.value = 1
	Columns.value = 1
	Margin_X.value = 0
	Margin_Y.value = 0
	Char_Arrangement.text = ""
	current_tex_path = ""
	current_file_path = ""
	get_tree().call_group("SpCharData","_on_button_pressed") #delete existing SpCharData nodes
	for g in get_tree().get_nodes_in_group("SheetData"): #regain control if locked
		g.editable = true

func fix_dir_path(path : String): #replaces "\" with "/" (windows is an ass abt this)
	var new_path := ""
	for c in path.length():
		if path.unicode_at(c) == 92: #unicode for \
			new_path += "/"
		else:
			new_path += path[c]
	return new_path

### Connections ###
func _on_open_button_button_up():
	Open_Dialog.visible = true

func _on_open_dialog_file_selected(path):
	reset()
	path = fix_dir_path(path)
	
	#update it w/ new info
	if !FileAccess.file_exists(path): #file couldn't be loaded, shouldnt happen but just in case it does - this is here
		Error_Dialog.dialog_text = "The selected file has not been found and failed to load\n                                   please try again"
		Error_Dialog.size = Vector2(435,120)
		Error_Dialog.visible = true
		return
	current_file_path = path
	if path.ends_with(".fnt"):
		load_font(path)
		return
	
	current_tex_path = path.substr(path.rfind("/")+1)
	Tex_Display.texture = ImageTexture.create_from_image(Image.load_from_file(path))
	Tex_Display.visible = true
	Loaded_Texture_Label.text = "Loaded: "+current_tex_path
	%"ExportButton".disabled = false #prevent exports w/o an image loaded
