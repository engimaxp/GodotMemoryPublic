extends Popup

@onready var texture_rect:TextureRect = $TextureRect as TextureRect

var pos:Vector2 = Vector2(0,0):
	set(value):
		pos = value
		if is_inside_tree():
			self.position = pos

var tex:ImageTexture :
	set(value):
		tex = value
		if is_instance_valid(texture_rect) and tex != null:
			texture_rect.texture = tex
			self.size = tex.get_size().clamp(Vector2(0,0),texture_rect.get_viewport_rect().size)
			if Vector2(self.size) < tex.get_size():
				texture_rect.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_WIDTH
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			
func _ready():
	self.tex = tex
	self.pos = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_rect_gui_input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		self.queue_free()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		self.queue_free()
