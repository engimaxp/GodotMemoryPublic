extends CanvasLayer
@onready var label = %Label
@onready var panel_container = %PanelContainer

func _ready():
	Signals.ballon_pop.connect(animate_show)
	panel_container.modulate.a = 0
	panel_container.scale = Vector2.ZERO
	
func animate_show(msg):
	label.text = msg
	await get_tree().process_frame
	panel_container.pivot_offset = panel_container.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel_container,"modulate:a",1.0,0.5)
	tween.parallel().tween_property(panel_container,"scale",Vector2.ONE,0.5)
	tween.tween_interval(3.0)
	tween.tween_property(panel_container,"modulate:a",0.0,1.0)
	tween.parallel().tween_property(panel_container,"scale",Vector2.ZERO,1.0)
	
	
