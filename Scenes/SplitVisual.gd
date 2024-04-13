extends Control
#creates lines in a grid based on the amount of rows and columns given
#disable grid_enabled to allow placing lines off-grid

var grid_enabled := true
@onready var Tex = get_parent()
@export var use_alt_pallete := false #temp, have this be set in the edit window or somewhere else in the ui
var mat = preload("res://Scenes/UI/OutlineMat.tres")

var rows := 1
var columns := 1
var margins := Vector2.ZERO
var sprite_size := Vector2(128,128)

const MARGIN_COLOR = Color(0.8,0.1,0.5,0.6)

#warning flags, prevent exports while any are enabled
var decimal_grid_size := true

func divide():
	var grid_size = Vector2(sprite_size.x/rows-margins.x,sprite_size.y/columns-margins.y)
	if floor(grid_size) != grid_size: #format doesn't allow decimals, abort req
		decimal_grid_size = true
		return
	decimal_grid_size = false
	
	#remove excess nodes
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	#find rows/columns
	for y in columns:
		for x in rows:
			var box = ColorRect.new()
			box.color = Color.WHITE
			box.size = grid_size
			box.material = preload("res://Scenes/UI/OutlineMat.tres")
			box.material.set_shader_parameter("total_size",grid_size)
			box.material.set_shader_parameter("alt_pallete",1.0 if use_alt_pallete else 0.0)
			
			#add gaps for margins
			var margin_offset = Vector2.ZERO
			if margins.x != 0:
				margin_offset.x = margins.x*x+floor(margins.x/2) #base value
			if margins.y != 0:
				margin_offset.y = margins.y*y+floor(margins.y/2)
			
			box.position = Vector2(x,y)*grid_size+margin_offset
			add_child(box)
			
			#apply margins
			if margins.x != 0 && y == 0:
				var line = ColorRect.new()
				line.color = MARGIN_COLOR
				line.size = Vector2(margins.x if x > 0 else floor(margins.x/2),sprite_size.y)
				line.position = Vector2(x,y)*grid_size+margin_offset-Vector2(line.size.x,floor(margins.y/2))
				add_child(line)
				
				if x == rows-1:
					var final_line = ColorRect.new()
					final_line.color = MARGIN_COLOR
					final_line.size = Vector2(ceil(margins.x/2),sprite_size.y)
					final_line.position = sprite_size-final_line.size
					add_child(final_line)
			
			if margins.y != 0:
				var line = ColorRect.new()
				line.color = MARGIN_COLOR
				line.size = Vector2(grid_size.x,margins.y if y > 0 else floor(margins.y/2))
				line.position = Vector2(x,y)*grid_size+margin_offset-Vector2(0,line.size.y)
				add_child(line)
				
				if y == columns-1:
					var final_line = ColorRect.new()
					final_line.color = MARGIN_COLOR
					final_line.size = Vector2(grid_size.x,ceil(margins.y/2))
					final_line.position = Vector2(x,y+1)*grid_size+margin_offset
					add_child(final_line)

func divide_unlimited(): #for non-grid textures
	if owner.char_cache.size() == 0: #nothing to display (none)
		return
	
	for c in owner.char_cache:
		var box = ColorRect.new()
		box.color = Color.WHITE
		box.size.x = c.width
		box.size.y = c.height
		box.position.x = c.x
		box.position.y = c.y
		box.material = mat
		box.material.set_shader_parameter("total_size",box.size)
		box.material.set_shader_parameter("alt_pallete",1.0 if use_alt_pallete else 0.0)
		
		add_child(box)

### Signals ###
func _on_rows_value_changed(value):
	rows = value
	if grid_enabled:
		divide()

func _on_columns_value_changed(value):
	columns = value
	if grid_enabled:
		divide()

func _on_margin_x_value_changed(value):
	margins.x = value
	if grid_enabled:
		divide()

func _on_margin_y_value_changed(value):
	margins.y = value
	if grid_enabled:
		divide()

func _on_open_dialog_file_selected(_path):
	await get_tree().physics_frame
	if get_parent().texture != null:
		sprite_size = get_parent().texture.get_size()
	else:
		sprite_size = Vector2(128,128)
	if grid_enabled:
		divide()
