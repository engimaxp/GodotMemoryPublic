extends CanvasLayer
@onready var file_dialog = $FileDialog
var tool_info:Dictionary:
	set(val):
		tool_info = val
		if tool_info!=null and not tool_info.is_empty():
			if is_instance_valid(tool_exe_line_edit):
				refresh_widgets()

@onready var image_files_select_dialog = $ImageFilesSelectDialog
@onready var upload_icon = %UploadIcon

@onready var tool_exe_line_edit = %EngineExeLineEdit
@onready var link_line_edit = %LinkLineEdit
@onready var name_line_edit = %NameLineEdit
@onready var desc_edit = %DescEdit
@onready var tag_logic = %TagLogic
@onready var image_logic = %ImageLogic

var icon_file_path
var icon_info
signal refresh

func _on_close_pressed():
	self.hide()
	reset_all()

func reset_all():
	tool_info = {}
	link_line_edit.text = ""
	tool_exe_line_edit.text = ""
	name_line_edit.text = ""
	desc_edit.text = ""
	tag_logic.reset_data()
	image_logic.reset_data()
	icon_info = null
	icon_file_path = null
	image_logic.unbind_choose_window_callback()
	upload_icon.set("texture_normal",preload("res://assest/icon/ui/image.svg"))

func refresh_widgets():
	if tool_info["Icon"] != null and tool_info["Icon"].length() > 0:
		var icon_rt = Db.LoadImageFromDB(tool_info["Icon"])
		upload_icon.set("texture_normal",icon_rt[0])
		upload_icon.material = null
		icon_info = icon_rt[1]
		icon_file_path = icon_info["Path"]
	link_line_edit.text = tool_info["Link"]
	tool_exe_line_edit.text = tool_info["Directory"]
	name_line_edit.text = tool_info["Name"]
	desc_edit.text = tool_info["Desc"]
	
	var tags = Db.QueryTagNameByRelateId(tool_info["Id"],Constants.TagType.Tool)
	if tags!= null and not tags.is_empty():
		var tag_strings = []
		for t in tags:
			tag_strings.append(t["Name"])
		tag_logic.tag_info = tag_strings
	
	var images = Db.QueryImagesByRelateId(tool_info["Id"],Constants.TagType.Tool)
	if images != null and not images.is_empty():
		var img_dic_array = []
		for img in images:
			img_dic_array.append({
				"Id":img["Id"],
				"image":Utils.load_external_tex(img["NewPath"]),
				"select":true,
				"path":img["Path"]
			})
		image_logic.current_select_images_array = img_dic_array

func check_save()->bool:
	#todo 
	return true

func get_project_dir():
	var dir
	if tool_info != null and not tool_info.is_empty():
		dir = tool_info["Directory"]
	else:
		dir = tool_exe_line_edit.text
	if FileAccess.file_exists(dir):
		var fp = FileAccess.open(dir,FileAccess.READ).get_path_absolute()
		return fp.get_base_dir()
	return null
func _on_ok_pressed():
	if not check_save():
		return
	var tool_id
	var icon_id
	if icon_info == null:
		if icon_file_path == null:
			pass
		else:
			var cf = Files.copy_to_cache(icon_file_path)
			icon_id = cf[1]["Id"]
	else:
		if icon_file_path != null and icon_info["Path"] != icon_file_path:
			var cf = Files.copy_to_cache(icon_file_path)
			icon_id = cf[1]["Id"]
		else:
			icon_id = icon_info["Id"]
	if tool_info == null or tool_info.is_empty():
		tool_id = Db.addToolInfo({
			"Directory":tool_exe_line_edit.text,
			"Name":name_line_edit.text,
			"Link":link_line_edit.text,
			"Desc":desc_edit.text,
			"Icon":("" if icon_id == null else icon_id)
		})
		if not tag_logic.select_tag_ids.is_empty():
			Db.AddTagRelation(tag_logic.select_tag_ids,tool_id,Constants.TagType.Tool)
		if not image_logic.current_select_images_array.is_empty():
			Files.AddImageRelation(image_logic.current_select_images_array,tool_id,Constants.TagType.Tool)
	else:
		tool_id = tool_info.Id
		Db.saveToolInfo({
			"Id":tool_info.Id,
			"Link":link_line_edit.text,
			"Directory":tool_exe_line_edit.text,
			"Name":name_line_edit.text,
			"Desc":desc_edit.text,
			"Icon":("" if icon_id == null else icon_id)
		})
		Db.ReplaceTagRelation(tag_logic.select_tag_ids,tool_id,Constants.TagType.Tool)
		Files.ReplaceImageRelation(image_logic.current_select_images_array,tool_id,Constants.TagType.Tool)
	self.hide()
	reset_all()
	refresh.emit()

func _on_tool_executable_pressed():
	file_dialog.popup_centered()

func _on_file_dialog_dir_selected(path:String):
	var exist_tools = Db.QueryToolWithConditionFromDB("Directory = '%s'" % path,"")
	if exist_tools != null and exist_tools.size() > 0:
		reset_all()
		self.tool_info = exist_tools[0]
	else:
		tool_exe_line_edit.text = path
		var bd = tool_exe_line_edit.text.get_base_dir()
		var icon_file = ""
		for f in DirAccess.open(bd).get_files():
			if Utils.is_image(f):
				if f.to_lower().begins_with("icon"):
					icon_file = bd + "/" + f
					break
		if icon_file != "":
			icon_file_path = icon_file
			upload_icon.set("texture_normal",Utils.load_external_tex(icon_file))
			upload_icon.material = null
			
func _on_engine_exe_line_edit_text_submitted(new_text):
	if not DirAccess.dir_exists_absolute(new_text):
		return
	var dir = DirAccess.open(new_text)
	new_text = dir.get_current_dir()
	_on_file_dialog_dir_selected(new_text)

func _on_flow_container_visibility_changed():
	if visible:
		Global.accept_image_drop = true
		image_logic.bind_choose_window_callback()
	else:
		Global.accept_image_drop = false

func _on_image_files_select_dialog_file_selected(path):
	icon_file_path = path
	upload_icon.set("texture_normal",Utils.load_external_tex(icon_file_path))
	upload_icon.material = null
	
func _on_upload_icon_pressed():
	image_files_select_dialog.popup_centered()
