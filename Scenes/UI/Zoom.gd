extends Camera2D

@onready var Cooldown_Timer = $CooldownTimer
@onready var ZoomHitbox = owner.get_node("ZoomHitbox")
@onready var Zoom_Label = owner.get_node("CanvasLayer/UI/ZoomLabel")
var zoom_factor := 100.0
var zoom_levels := [25,50,75,100,200,300,400,500,600,700,800]

var allow_zoom_change := false

func _ready():
	global_position = get_parent().global_position + get_parent().size/2

func _input(event):
	if event is InputEventMouse: #prevents the scroll wheel from zooming when not hovered over the center area
		if event.position.x > ZoomHitbox.position.x && event.position.x < ZoomHitbox.position.x+ZoomHitbox.size.x:
			allow_zoom_change = true
		else:
			allow_zoom_change = false
	if Cooldown_Timer.time_left == 0 && allow_zoom_change:
		if InputMap.event_is_action(event, "Zoom In") && zoom_factor < 800:
			Cooldown_Timer.start()
			zoom_factor = zoom_levels[zoom_levels.find(floori(zoom_factor))+1]
			zoom = Vector2(zoom_factor,zoom_factor)/100
			Zoom_Label.text = "Zoom -- " + str(zoom_factor) + "%"
		if InputMap.event_is_action(event, "Zoom Out") && zoom_factor > 25:
			Cooldown_Timer.start()
			zoom_factor = zoom_levels[zoom_levels.find(floori(zoom_factor))-1]
			zoom = Vector2(zoom_factor,zoom_factor)/100
			Zoom_Label.text = "Zoom -- " + str(zoom_factor) + "%"
