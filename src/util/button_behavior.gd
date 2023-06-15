extends Node

@export var btn_paths:Array[NodePath]
# Called when the node enters the scene tree for the first time.
var btns = []
signal  button_pressed(btn_name)
func _ready():
	for btn_path in btn_paths:
		btns.append(get_node_or_null(btn_path))
	for btn in btns:
		btn.pressed.connect(_clicked)

func _clicked(p_btn):
	for btn in btns:
		if btn == p_btn:
			button_pressed.emit(btn.name)
		else:
			btn.is_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
