extends HBoxContainer
class_name  Tag
@onready var label = %Label
@onready var color_picker_button = $ColorPickerButton
@onready var delete = $PanelContainer2/MarginContainer/Delete
@export var id:String

@export var has_delete:bool = false:
	set(val):
		has_delete = val
		if is_instance_valid(delete):
			if not has_delete:
				delete.get_parent().get_parent().hide()
			else:
				delete.get_parent().get_parent().show()
		
@export var type:Constants.TagType = Constants.TagType.Engine
@export var sub_type:Constants.TagSubType = Constants.TagSubType.DEFAULT
@export var text:String = "C#":
	set(val):
		text = val
		if is_instance_valid(label):
			label.text = text

@export var color:Color = Color.BLACK:
	set(val):
		color = val
		if is_instance_valid(color_picker_button):
			color_picker_button.color = color

func _on_color_picker_button_popup_closed():
	if id != null and id.length() > 0:
		Db.UpdateTagColor(id,color_picker_button.color.to_html(false))

func _ready():
	self.text = text
	self.color = color
	label.get_parent().get_parent().get("theme_override_styles/panel")\
		.set("bg_color",Enums.white_color)
	delete.hide()
	self.has_delete = has_delete
	
func _on_mouse_entered():
#	print(self,"name","entered")
	label.get_parent().get_parent().get("theme_override_styles/panel")\
		.set("bg_color",Enums.gold_color)
	if has_delete:
		delete.show()

func refresh():
	label.get_parent().get_parent().get("theme_override_styles/panel")\
		.set("bg_color",Enums.white_color)
	
func make_unique_panel_style():
	label.get_parent().get_parent().set("theme_override_styles/panel",
	(label.get_parent().get_parent().get("theme_override_styles/panel")\
		.duplicate(true)))
	
func _on_mouse_exited():
#	print(self,"name","exited")
	label.get_parent().get_parent().get("theme_override_styles/panel")\
		.set("bg_color",Enums.white_color)
	if has_delete:
		delete.hide()
		
signal delete_pressed

func _on_delete_pressed():
	delete_pressed.emit()
	self.queue_free()

signal pressed
func _on_panel_container_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			pressed.emit()
