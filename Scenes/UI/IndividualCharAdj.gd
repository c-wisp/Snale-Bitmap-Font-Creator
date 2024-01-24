extends TabContainer
#handles character adjustments for SPchars and Kerning Pairs

@onready var Ind_Char_Adj = %"SPC Box"
@onready var Kerning_Pairs = %"KP Box"

var SPCharData_Base = preload("res://Scenes/UI/SPCharData.tscn")
var KerningPair_Base = preload("res://Scenes/UI/KerningPair.tscn")

func _on_add_adj_button_button_up():
	var new_child = SPCharData_Base.instantiate()
	Ind_Char_Adj.add_child(new_child)
	Ind_Char_Adj.move_child(new_child,2)
	await get_tree().physics_frame
	new_child.connect_to_autosave()

func _on_add_pair_button_button_up():
	var new_child = KerningPair_Base.instantiate()
	Kerning_Pairs.add_child(new_child)
	Kerning_Pairs.move_child(new_child,2)
	await get_tree().physics_frame
	new_child.connect_to_autosave()
