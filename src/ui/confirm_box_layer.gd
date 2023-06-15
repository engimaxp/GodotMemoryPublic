extends CanvasLayer
@onready var confirm = %Confirm
@onready var cancel = %Cancel
@onready var label = %Label
@onready var panel_container = $CenterContainer/PanelContainer
@onready var rich_text_label = %RichTextLabel
var current_callable:Callable
func _ready():
	self.hide()
	Signals.confirm_pop.connect(pop_up)
	panel_container.modulate.a = 0
	panel_container.pivot_offset = panel_container.size / 2.0
	panel_container.scale = Vector2.ZERO

func pop_up(msg,callback:Callable):
	self.show()
	current_callable = callback
	rich_text_label.text = "[center]%s[/center]" % msg
	var tween = create_tween()
	tween.tween_property(panel_container,"modulate:a",1.0,0.5)
	tween.parallel().tween_property(panel_container,"scale",Vector2.ONE,0.5)

func sink_down():
	var tween = create_tween()
	tween.tween_property(panel_container,"modulate:a",0.0,0.5)
	tween.parallel().tween_property(panel_container,"scale",Vector2.ZERO,0.5)
	tween.tween_callback(hide)

func call_ok():
	if current_callable != null:
		current_callable.call()
	sink_down()
