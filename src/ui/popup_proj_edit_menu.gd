extends CanvasLayer
@onready var file_dialog = $FileDialog
var proj_info:Dictionary:
	set(val):
		proj_info = val
		if proj_info!=null and not proj_info.is_empty():
			if is_instance_valid(proj_exe_line_edit):
				refresh_widgets()

@onready var icon_node = %Icon

@onready var proj_exe_line_edit = %EngineExeLineEdit
@onready var main_version_line_edit = %MainVersionLineEdit
@onready var version_line_edit = %VersionLineEdit
@onready var name_line_edit = %NameLineEdit
@onready var desc_edit = %DescEdit
@onready var tag_logic = %TagLogic
@onready var used_engine_options = %UsedEngineOptions
@onready var image_logic = %ImageLogic

var possible_engine_dic = {}
var icon_file_path
var icon_info
signal refresh


func _on_close_pressed():
	self.hide()
	reset_all()

func reset_all():
	proj_info = {}
	version_line_edit.text = ""
	proj_exe_line_edit.text = ""
	name_line_edit.text = ""
	main_version_line_edit.text = ""
	desc_edit.text = ""
	used_engine_options.select(-1)
	tag_logic.reset_data()
	image_logic.reset_data()
	used_engine_options.clear()
	icon_info = null
	icon_file_path = null
	icon_node.texture = null
	image_logic.unbind_choose_window_callback()

func refresh_widgets():
	var engines = Db.QueryEngineWithConditionFromDB("MainVersion = %d and IsDelete = 0" % proj_info["MainVersion"],"")
	load_to_option_list(engines)
	var icon_rt = Db.LoadImageFromDB(proj_info["Icon"])
	icon_node.texture = icon_rt[0]
	icon_info = icon_rt[1]
	icon_file_path = icon_info["Path"]
	version_line_edit.text = proj_info["Version"]
	proj_exe_line_edit.text = proj_info["Directory"]
	name_line_edit.text = proj_info["Name"]
	main_version_line_edit.text = str(proj_info["MainVersion"])
	desc_edit.text = proj_info["Desc"]
	used_engine_options.select(used_engine_options.\
		get_item_index(possible_engine_dic[proj_info["EngineId"]]))
	var tags = Db.QueryTagNameByProjId(proj_info["Id"])
	if tags!= null and not tags.is_empty():
		var tag_strings = []
		for t in tags:
			tag_strings.append(t["Name"])
		tag_logic.tag_info = tag_strings
	
	var images = Db.QueryImagesByRelateId(proj_info["Id"],Constants.TagType.Proj)
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
	if proj_info != null and not proj_info.is_empty():
		return proj_info["Directory"]
	return null
	
func _on_ok_pressed():
	if not check_save():
		return
	var proj_id
	var icon_id
	if icon_info == null:
		var cf = Files.copy_to_cache(icon_file_path)
		icon_id = cf[1]["Id"]
	else:
		icon_id = icon_info["Id"]
	if proj_info == null or proj_info.is_empty():
		proj_id = Db.addProjInfo({
			"Version":version_line_edit.text,
			"Directory":proj_exe_line_edit.text,
			"Name":name_line_edit.text,
			"MainVersion":main_version_line_edit.text,
			"Desc":desc_edit.text,
			"EngineId":used_engine_options.get_selected_metadata()["EngineId"],
			"Icon":icon_id
		})
		if not tag_logic.select_tag_ids.is_empty():
			Db.AddTagRelation(tag_logic.select_tag_ids,proj_id,Constants.TagType.Proj)
		if not image_logic.current_select_images_array.is_empty():
			Files.AddImageRelation(image_logic.current_select_images_array,proj_id,Constants.TagType.Proj)
	else:
		proj_id = proj_info.Id
		Db.saveProjInfo({
			"Id":proj_info.Id,
			"Version":version_line_edit.text,
			"Directory":proj_exe_line_edit.text,
			"Name":name_line_edit.text,
			"MainVersion":main_version_line_edit.text,
			"EngineId":used_engine_options.get_selected_metadata()["EngineId"],
			"Desc":desc_edit.text,
			"Icon":icon_id
		})
		Db.ReplaceTagRelation(tag_logic.select_tag_ids,proj_id,Constants.TagType.Proj)
		Files.ReplaceImageRelation(image_logic.current_select_images_array,proj_id,Constants.TagType.Proj)
	self.hide()
	reset_all()
	refresh.emit()

func _on_proj_executable_pressed():
	file_dialog.popup_centered()

func _ready():
	print("ready")

func _on_file_dialog_dir_selected(path:String):
	var exist_projs = Db.QueryProjWithConditionFromDB("Directory = '%s' and IsDelete = 0" % path,"")
	if exist_projs != null and exist_projs.size() > 0:
		reset_all()
		self.proj_info = exist_projs[0]
	else:
		proj_exe_line_edit.text = path
		print(path)
		if not FileAccess.file_exists(path + "/project.godot"):
			proj_exe_line_edit.text = ""
			return
		var c = ConfigFile.new()
		c.load(path + "/project.godot")
		var v = c.get_value("","config_version",4)
		var main_version = 0
		if v == 4:
			main_version_line_edit.text = "3"
			main_version = 3
			version_line_edit.text = "3.5"
		elif v == 5:
			var features = c.get_value("application","config/features",PackedStringArray(["4.0","FF"]))
			main_version_line_edit.text = "4"
			main_version = 4
			version_line_edit.text = features[0]
		
		var proj_name = c.get_value("application","config/name","godot_project")
		name_line_edit.text = proj_name
		
		var icon_file = c.get_value("application","config/icon","")
		if icon_file != "":
			var base_dir = icon_file.trim_prefix("res://").get_base_dir()
			if base_dir.length() > 0:
				icon_file_path = path + "/" + base_dir + "/" + icon_file.get_file()
			else:
				icon_file_path = path + "/" + icon_file.get_file()
		else:
			icon_file_path = "res://data/cache/img/g867.png" if main_version == 3 else "res://data/cache/img/g866.png"
			icon_file_path = FileAccess.open(icon_file_path,FileAccess.READ).get_path_absolute()
		icon_node.texture = Utils.load_external_tex(icon_file_path)
		var engines = Db.QueryEngineWithConditionFromDB("MainVersion = %d and IsDelete = 0" % main_version,"")
		load_to_option_list(engines)
	
func load_to_option_list(engines:Array):
	used_engine_options.clear()
	possible_engine_dic.clear()
	if engines == null or engines.is_empty():
		return
	engines.sort_custom(func(a, b): return a["IsDefault"] > b["IsDefault"])
	var idx = 0
	for e in engines:
		var s = "[** %d ** (%s) ] %s" % \
			[e["MainVersion"],e["Version"],e["Name"]]
		used_engine_options.add_item(s,idx)
		possible_engine_dic[e["Id"]] = idx
		used_engine_options.set_item_metadata(idx,{"EngineId":e["Id"]})
		idx += 1
	used_engine_options.select(0)
	
	
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
