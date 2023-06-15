extends PanelContainer

@export var texture:Texture2D
@export var text:String
@onready var texture_rect = $MarginContainer/VBoxContainer/TextureRect
@onready var label = $MarginContainer/VBoxContainer/Label
@export var is_default:bool = false
signal pressed(btn)

var is_pressed:bool:
	set(val):
		is_pressed = val
		if is_instance_valid(texture_rect):
			if is_pressed:
				texture_rect.material.set("shader_parameter/tint_color",Enums.gold_color)
				label.set("theme_override_colors/font_color",Enums.gold_color)
				self.get("theme_override_styles/panel").set("bg_color",Enums.dark_blue_shallow_color)
				emit_signal("pressed",self)
			else:
				texture_rect.material.set("shader_parameter/tint_color",Enums.gray_shallow_color)
				label.set("theme_override_colors/font_color",Enums.gray_shallow_color)
				self.get("theme_override_styles/panel").set("bg_color",Color.TRANSPARENT)
			
var is_hover:bool:
	set(val):
		is_hover = val
		if is_pressed:
			return
		if is_instance_valid(texture_rect):
			if is_hover:
				texture_rect.material.set("shader_parameter/tint_color",Enums.gold_color)
				label.set("theme_override_colors/font_color",Enums.gold_color)
			else:
				texture_rect.material.set("shader_parameter/tint_color",Enums.gray_shallow_color)
				label.set("theme_override_colors/font_color",Enums.gray_shallow_color)
			
func _ready():
	texture_rect.texture = texture
	label.text = text
	self.is_hover = false
	if is_default:
		self.is_pressed = true
	else:
		self.is_pressed = false
	

func _on_mouse_entered():
	self.is_hover = true
func _on_mouse_exited():
	self.is_hover = false

func _on_gui_input(event):
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		self.is_pressed = true
