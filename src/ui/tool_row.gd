extends PanelContainer

const ImageContainer = preload("res://src/ui/image_container.tscn")

@onready var link_name = %LinkName
@onready var locate = %Locate
@onready var name_label = %ToolName
@onready var icon = %Icon
@onready var desc_node = %Desc
@onready var star = %star

@onready var run_button = %OpenWIthEngine
@onready var refresh_button = %RefreshStatus
@onready var edit_button = %Edit
@onready var open_dir_button = %OpenDir
@onready var star_button = %Star
@onready var delete_button = %Delete
@onready var url_button = %Url

@onready var tool_text_desc_container = %ToolTextDescContainer
@onready var tool_image_desc_container = %ToolImageDescContainer

const TagScene = preload("res://src/ui/tag.tscn")

signal edit_pressed(dic,from)
signal refresh

@onready var tag_container = %TagContainer
var icon_info

func swap_display():
	if tool_text_desc_container.visible:
		tool_text_desc_container.hide()
		tool_image_desc_container.show()
	else:
		tool_text_desc_container.show()
		tool_image_desc_container.hide()

var tool_info:Dictionary:
	set(val):
		tool_info = val
		if is_instance_valid(name_label):
			if tool_info["Star"]:
				star.show()
				star_button.toggle_value = true
			else:
				star.hide()
				star_button.toggle_value = false
			var desc = tool_info["Desc"]
			desc_node.text = desc
			if tool_info["Icon"] != null and tool_info["Icon"].length() > 0:
				var icon_rt = Db.LoadImageFromDB(tool_info["Icon"])
				icon.texture = icon_rt[0]
				icon_info = icon_rt[1]
				icon.material = null
			name_label.text = tool_info["Name"]
			locate.text = tool_info["Directory"]
			if tool_info["Link"] != null and tool_info["Link"].length() > 0:
				url_button.disabled = false
				url_button.refresh()
				link_name.text = tool_info["Link"]
			else:
				url_button.disabled = true
				url_button.refresh()
				link_name.text = ""
#			for b in [run_button,refresh_button,edit_button\
#				,open_dir_button,star_button,delete_button]:
#					b.refresh()
			var tags = Db.QueryTagNameByRelateId(tool_info["Id"],Constants.TagType.Tool)
			
			for c in tag_container.get_children():
				c.queue_free()
			for ti in tags:
				var t = TagScene.instantiate()
				t.text = ti["Name"]
				t.color = Color.from_string(ti["Color"],Color.WHITE)
				t.id = ti["Id"]
				t.type = ti["Type"]
				t.sub_type = ti["SubType"]
				t.has_delete = false
				tag_container.add_child(t)
				
			##  images
			var unit_width = (float(self.size.x - (4 * 5) )/ 5.0)
			var images = Db.QueryImagesByRelateId(tool_info["Id"],Constants.TagType.Tool)
			if images != null and not images.is_empty():
				var img_dic_array = []
				var i = 0
				for img in images:
					i += 1
					var t = ImageContainer.instantiate()
					t.texture = Utils.load_external_tex(img["NewPath"])
					t.img_path = img["Path"]
					t.id = img["Id"]
					t.unit_width = unit_width
					t.readonly = true
					t.index = i
					tool_image_desc_container.add_child(t)

func _ready():
	self.tool_info = tool_info

func _on_run_pressed():
	open_tool()
	
func open_tool():
	var ext = tool_info["Directory"].get_extension()
	if ext in ["exe","bat","java"]:
		OS.create_process(tool_info["Directory"],[])

func _on_refresh_pressed():
	pass
	
func _on_edit_pressed():
	edit_pressed.emit(tool_info,self)

func _on_open_dir_pressed():
	OS.shell_open(str("file://", tool_info["Directory"].trim_suffix(tool_info["Directory"].get_file())))

func _on_star_pressed():
	star_button.toggle_value = not star_button.toggle_value
	tool_info["Star"] = star_button.toggle_value
	Db.UpdateToolStar(tool_info["Id"],tool_info["Star"])
	if tool_info["Star"]:
		star.show()
	else:
		star.hide()

func _on_delete_pressed():
	Signals.confirm_pop.emit(tr("Do you really want to delete [color=%s]%s[/color]?") % [Enums.red_color.to_html(),tool_info["Name"]],\
	func():
		Db.deleteTool(tool_info["Id"])
		refresh.emit()
		)
		

func _on_copy_dir_pressed():
	DisplayServer.clipboard_set(tool_info["Directory"].trim_suffix(tool_info["Directory"].get_file()))
	Signals.ballon_pop.emit(tr("Tool Directory Copied To ClipBoard"))
	

func _on_url_pressed():
	OS.shell_open(tool_info["Link"])
