extends ColorRect

var margin_cache := Vector2.ZERO

func _ready():
	material.set_shader_parameter("rows",1)
	material.set_shader_parameter("columns",1)

func _on_rows_value_changed(value):
	material.set_shader_parameter("rows",value)

func _on_columns_value_changed(value):
	material.set_shader_parameter("columns",value)

func _on_open_dialog_confirmed():
	await get_tree().process_frame
	material.set_shader_parameter("sprite_size",get_parent().texture.get_size())

func _on_margin_y_value_changed(value):
	margin_cache.x = value
	material.set_shader_parameter("margins",margin_cache)

func _on_margin_x_value_changed(value):
	margin_cache.y = value
	material.set_shader_parameter("margins",margin_cache)
