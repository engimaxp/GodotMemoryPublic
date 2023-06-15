extends Node

const max_icon = preload("res://assest/icon/ui/window-maximize.svg")
const restore_icon = preload("res://assest/icon/ui/window-restore.svg")

@onready var panels = [$VBoxContainer/HBoxContainer2/Engine, $VBoxContainer/HBoxContainer2/Proj, $VBoxContainer/HBoxContainer2/Asset, $VBoxContainer/HBoxContainer2/Tool, $VBoxContainer/HBoxContainer2/Setting]
@onready var side_button_group = %SideButtonGroup

@onready var engine = %Engine
@onready var proj = %Proj
@onready var asset = %Asset
@onready var tool = %Tool
@onready var setting = %Setting

@onready var mapping = {
	"Engine":engine,
	"Proj":proj,
	"Asset":asset,
	"Tool":tool,
	"Setting":setting
}
@onready var v_box_container = $VBoxContainer/HBoxContainer2/VBoxContainer/VBoxContainer

func _ready():
	side_button_group.button_pressed.connect(flip_panel)
	var od = Global.config.get_value("Setting", "DefaultPanel", "Engine") 
	for x in v_box_container.get_children():
		if "is_default" in x:
#			if x.is_default:
			if od == x.name:
				mapping[x.name].show()
				mapping[x.name].load_panel()
				x.is_pressed = true
			else:
				mapping[x.name].hide()
				x.is_pressed = false
#	FileAccess.open("E:/workspace/godot/godot_4_latest/godot/bin/godot.windows.editor.x86_64.exe")

func flip_panel(p_name):
	for panel in panels:
		if panel.name == p_name:
			panel.show()
			panel.load_panel()
		else:
			panel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

