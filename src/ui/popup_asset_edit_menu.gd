extends CanvasLayer
@onready var file_dialog = $FileDialog
var asset_info:Dictionary:
	set(val):
		asset_info = val
		if asset_info!=null and not asset_info.is_empty():
			if is_instance_valid(asset_exe_line_edit):
				refresh_widgets()

@onready var asset_exe_line_edit = %EngineExeLineEdit
@onready var name_line_edit = %NameLineEdit
@onready var desc_edit = %DescEdit
@onready var link_line_edit = %LinkLineEdit
@onready var copy_right_edit = %CopyRightEdit
@onready var tag_logic = %TagLogic
@onready var image_logic = %ImageLogic

signal refresh
func _on_close_pressed():
	self.hide()
	reset_all()

func reset_all():
	asset_info = {}
	link_line_edit.text = ""
	asset_exe_line_edit.text = ""
	name_line_edit.text = ""
	copy_right_edit.text = ""
	desc_edit.text = ""
	tag_logic.reset_data()
	image_logic.reset_data()
	image_logic.unbind_choose_window_callback()

func refresh_widgets():
	copy_right_edit.text = asset_info["CopyRight"]
	asset_exe_line_edit.text = asset_info["Directory"]
	name_line_edit.text = asset_info["Name"]
	link_line_edit.text = asset_info["Link"]
	desc_edit.text = asset_info["Desc"]
	var tags = Db.QueryTagNameByRelateId(asset_info["Id"],Constants.TagType.Asset)
	if tags!= null and not tags.is_empty():
		var tag_strings = []
		for t in tags:
			tag_strings.append(t["Name"])
		tag_logic.tag_info = tag_strings
	
	var images = Db.QueryImagesByRelateId(asset_info["Id"],Constants.TagType.Asset)
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
	if asset_info != null and not asset_info.is_empty():
		return asset_info["Directory"].trim_suffix(asset_info["Directory"].get_file())
	else:
		return asset_exe_line_edit.text
	
func _on_ok_pressed():
	if not check_save():
		return
	var asset_id
	if asset_info == null or asset_info.is_empty():
		asset_id = Db.addAssetInfo({
			"Link":link_line_edit.text,
			"Directory":asset_exe_line_edit.text,
			"Name":name_line_edit.text,
			"CopyRight":copy_right_edit.text,
			"Desc":desc_edit.text,
		})
		if not tag_logic.select_tag_ids.is_empty():
			Db.AddTagRelation(tag_logic.select_tag_ids,asset_id,Constants.TagType.Asset)
		if not image_logic.current_select_images_array.is_empty():
			Files.AddImageRelation(image_logic.current_select_images_array,asset_id,Constants.TagType.Asset)
	else:
		asset_id = asset_info.Id
		Db.saveAssetInfo({
			"Id":asset_info.Id,
			"Link":link_line_edit.text,
			"Directory":asset_exe_line_edit.text,
			"Name":name_line_edit.text,
			"CopyRight":copy_right_edit.text,
			"Desc":desc_edit.text,
		})
		Db.ReplaceTagRelation(tag_logic.select_tag_ids,asset_id,Constants.TagType.Asset)
		Files.ReplaceImageRelation(image_logic.current_select_images_array,asset_id,Constants.TagType.Asset)
	self.hide()
	reset_all()
	refresh.emit()

func _on_asset_executable_pressed():
	file_dialog.popup_centered()

func _on_file_dialog_dir_selected(path:String):
	var exist_assets = Db.QueryAssetWithConditionFromDB("Directory = '%s'" % path,"")
	if exist_assets != null and exist_assets.size() > 0:
		reset_all()
		self.asset_info = exist_assets[0]
	else:
		asset_exe_line_edit.text = path
		print(path)
	
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
