extends PanelContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var is_loaded = false

func load_panel():
	if is_loaded:
		return
	_load_panel()
	is_loaded = true

func _load_panel():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
