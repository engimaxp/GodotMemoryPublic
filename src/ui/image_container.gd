extends MarginContainer

var unit_width
var img_path
var id
var is_hover = false
var hover_time = 0

@export var readonly = false:
	set(val):
		readonly = val
		if is_instance_valid(reference_rect):
			if readonly:
				reference_rect.hide()
				label.get_parent().get_parent().hide()
			else:
				reference_rect.show()
				label.get_parent().get_parent().show()

var is_selected:bool = false:
	set(val):
		is_selected = val
		if is_instance_valid(texture_rect):
			if is_selected:
				panel_container.get("theme_override_styles/panel")\
					.set("bg_color",Enums.green_color)
				reference_rect.set("border_color",Enums.green_color)
			else:
				panel_container.get("theme_override_styles/panel")\
					.set("bg_color",Enums.white_color)
				reference_rect.set("border_color",Enums.white_color)

var index: int = 0 :
	set(value):
		index = value
		if is_instance_valid(label):
			label.text = str(index)

var texture:ImageTexture :
	set(value):
		texture = value
		if is_instance_valid(texture_rect):
			texture_rect.texture = texture
			texture_rect.custom_minimum_size.x = unit_width
			
@onready var reference_rect = $ReferenceRect
@onready var panel_container = $PanelContainer/MarginContainer/MarginContainer/PanelContainer
@onready var texture_rect = $PanelContainer/MarginContainer/TextureRect
@onready var label = $PanelContainer/MarginContainer/MarginContainer/PanelContainer/MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	self.index = index
	self.texture = texture
	self.is_selected = is_selected
	self.readonly = readonly

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_hover:
		hover_time += delta
		if hover_time > 0.5:
			Global.pop_up_image_preview(texture,get_global_mouse_position())
			clear_hover()

func clear_hover():
	is_hover = false
	hover_time = 0

func _on_panel_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if readonly:
				return
			is_selected = !is_selected
			Global.mouse_clicked_means_select = is_selected
			clear_hover()

func _on_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if readonly:
			return
		is_selected = Global.mouse_clicked_means_select
		clear_hover()
	else:
		is_hover = true
