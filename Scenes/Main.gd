extends Node2D
#holds global data & creates fonts

@onready var Exporter = $"Font Exporter"
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
var char_cache := [] #used for sprites w/ non-grid textures (specifically on .fnt load)

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
					var index = sp_char_adj[String.chr(c.id)]
					current_font.chars[c].width = index.char_size.x if index.char_size.x != 0 else current_font.chars[c].width
					current_font.chars[c].height = index.char_size.y if index.char_size.y != 0 else current_font.chars[c].height
					current_font.chars[c].xadvance = index.advance if index.advance != 0 else current_font.chars[c].width+2
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
					letter.xoffset = char_offset.x
					letter.yoffset = char_offset.y
					if sp_char_adj.keys().has(char_rows[c][r]):
						var index = sp_char_adj[char_rows[c][r]]
						letter.width = index.char_size.x if index.char_size.x != 0 else char_size.x
						letter.height = index.char_size.y if index.char_size.y != 0 else char_size.y
						letter.xadvance = index.advance if index.advance != 0 else char_size.x+2
					else:
						letter.width = char_size.x
						letter.height = char_size.y
						letter.xadvance = char_size.x+2
					
					var letter_pos = (char_size+margins)*Vector2(r,c)+margins/2
					letter.x = letter_pos.x
					letter.y = letter_pos.y
					
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
			"common":
				var data_array = data.split(" ",false)
				Font_Size.value = data_array[2].to_int()
				Line_Spacing.value = data_array[1].to_int()/Font_Size.value
			"page":
				var tex_path = data.substr(data.find("file=")).trim_prefix('file="')
				tex_path = Open_Dialog.current_dir+"/"+tex_path.substr(0,tex_path.rfind('"'))
				current_tex_path = tex_path.right(-tex_path.rfind("/")-1)
				Tex_Display.texture = load(tex_path)
				Tex_Display.visible = true
				Loaded_Texture_Label.text = "Loaded: "+Open_Dialog.current_file
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
				chardata.append(new_char)
			"kerning":
				var data_array = data.split(" ",false)
				var new_pair = Individual_Char_Adj.KerningPair_Base.instantiate()
				Kerning_Pairs.add_child(new_pair)
				new_pair.pair = String.chr(data_array[1].to_int())+String.chr(data_array[2].to_int())
				new_pair.offset = data_array[3].to_int()
				new_pair.update_text()
	
	#fix the char_arrangement to fit the row/column ct
	#shouldnt really do anything (aside from visuals) if the texture isnt a grid
	if tex_is_grid:
		for c in Columns.value:
			Char_Arrangement.text = Char_Arrangement.text.insert(Rows.value*(c+1)+c,"\n")
		var textcache = Char_Arrangement.text.trim_suffix("\n")
		Char_Arrangement.clear()
		Char_Arrangement.text = textcache
	else:
		char_cache.append_array(chardata)

### Connections ###
func _on_open_button_button_up():
	Open_Dialog.visible = true

func _on_open_dialog_confirmed():
	#reset data
	Font_Name.text = ""
	Font_Size.value = 1
	Line_Spacing.value = 1
	Rows.value = 1
	Columns.value = 1
	Margin_X.value = 0
	Margin_Y.value = 0
	Char_Arrangement.text = ""
	current_tex_path = ""
	get_tree().call_group("SpCharData","_on_button_pressed") #delete existing SpCharData nodes
	for g in get_tree().get_nodes_in_group("SheetData"): #regain control if locked
		g.editable = true
	
	#update it w/ new info
	if Open_Dialog.current_file.ends_with(".fnt"):
		load_font(Open_Dialog.current_path)
		return
	current_tex_path = Open_Dialog.current_file
	Tex_Display.texture = load(Open_Dialog.current_path)
	Tex_Display.visible = true
	Loaded_Texture_Label.text = "Loaded: "+current_tex_path
	%"ExportButton".disabled = false #prevent exports w/o an image loaded
