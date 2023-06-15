extends PanelContainer

const ImageContainer = preload("res://src/ui/image_container.tscn")

@onready var version_node = %Version
@onready var main_version_node = %MainVersion
@onready var locate = %Locate
@onready var name_label = %ProjName
@onready var icon = %Icon
@onready var engine_name = %EngineName
@onready var desc_node = %Desc
@onready var star = %star

@onready var run_button = %OpenWIthEngine
@onready var refresh_button = %RefreshStatus
@onready var edit_button = %Edit
@onready var open_dir_button = %OpenDir
@onready var star_button = %Star
@onready var delete_button = %Delete

@onready var project_text_desc_container = %ProjectTextDescContainer
@onready var project_image_desc_container = %ProjectImageDescContainer

const TagScene = preload("res://src/ui/tag.tscn")

signal edit_pressed(dic,from)
signal refresh

@onready var tag_container = %TagContainer
var engine_info
var icon_info

func swap_display():
	if project_text_desc_container.visible:
		project_text_desc_container.hide()
		project_image_desc_container.show()
	else:
		project_text_desc_container.show()
		project_image_desc_container.hide()

var proj_info:Dictionary:
	set(val):
		proj_info = val
		if is_instance_valid(name_label):
			if proj_info["Star"]:
				star.show()
				star_button.toggle_value = true
			else:
				star.hide()
				star_button.toggle_value = false
			var desc = proj_info["Desc"]
			desc_node.text = desc
			var icon_rt = Db.LoadImageFromDB(proj_info["Icon"])
			icon.texture = icon_rt[0]
			icon_info = icon_rt[1]
			name_label.text = proj_info["Name"]
			locate.text = proj_info["Directory"]
			main_version_node.text = str(proj_info["MainVersion"])
			version_node.text = str(proj_info["Version"])
#			for b in [run_button,refresh_button,edit_button\
#				,open_dir_button,star_button,delete_button]:
#					b.refresh()
			var tags = Db.QueryTagNameByProjId(proj_info["Id"])
			engine_info = Db.GetEngineById(proj_info["EngineId"])
			if engine_info != null:
				engine_name.text = "%s [%s]" % \
			[engine_info["Name"],engine_info["Version"]]
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
			var images = Db.QueryImagesByRelateId(proj_info["Id"],Constants.TagType.Proj)
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
					project_image_desc_container.add_child(t)

func _ready():
	self.proj_info = proj_info

func _on_run_pressed():
	open_proj()
	
func open_proj():
	OS.create_process(engine_info["Directory"],["-e","--path",proj_info["Directory"]])

func _on_refresh_pressed():
	var path = proj_info["Directory"]
	if not FileAccess.file_exists(path + "/project.godot"):
		return
	var c = ConfigFile.new()
	c.load(path + "/project.godot")
	var v = c.get_value("","config_version",4)
	if v == 4:
		proj_info["MainVersion"] = 3
		proj_info["Version"] = "3.5"
	elif v == 5:
		var features = c.get_value("application","config/features",PackedStringArray(["4.0","FF"]))
		proj_info["MainVersion"] = 4
		proj_info["Version"] = features[0]
		
	var proj_name = c.get_value("application","config/name","godot_project")
	proj_info["Name"] = proj_name
	var icon_file_path
	var icon_file = c.get_value("application","config/icon","")
	if icon_file != "":
		var base_dir = icon_file.trim_prefix("res://").get_base_dir()
		if base_dir.length() > 0:
			icon_file_path = path + "/" + base_dir + "/" + icon_file.get_file()
		else:
			icon_file_path = path + "/" + icon_file.get_file()
	else:
		icon_file_path = "res://data/cache/img/g867.png" if proj_info["MainVersion"] == 3 else "res://data/cache/img/g866.png"
		icon_file_path = FileAccess.open(icon_file_path,FileAccess.READ).get_path_absolute()
	if FileAccess.get_md5(icon_file_path) != FileAccess.get_md5(icon_info["NewPath"]):
		print("file_copied")
		var cf = Files.copy_to_cache(icon_file_path)
		var icon_id = cf[1]["Id"]
		icon_info = cf[1]
		proj_info["Icon"] = icon_id
	var id = proj_info["Id"]
	Db.saveProjInfo(proj_info)
	proj_info["Id"] = id
	self.proj_info = proj_info
	
func _on_edit_pressed():
	edit_pressed.emit(proj_info,self)

func _on_open_dir_pressed():
	OS.shell_open(str("file://", proj_info["Directory"]))

func _on_star_pressed():
	star_button.toggle_value = not star_button.toggle_value
	proj_info["Star"] = star_button.toggle_value
	Db.UpdateProjStar(proj_info["Id"],proj_info["Star"])
	if proj_info["Star"]:
		star.show()
	else:
		star.hide()

func _on_delete_pressed():
	Signals.confirm_pop.emit(tr("Do you really want to delete [color=%s]%s[/color]?") % [Enums.red_color.to_html(),proj_info["Name"]],\
	func():
		Db.deleteProj(proj_info["Id"])
		refresh.emit()
		)
		

func _on_copy_dir_pressed():
	DisplayServer.clipboard_set(proj_info["Directory"])
	Signals.ballon_pop.emit(tr("Project Directory Copied To ClipBoard"))
	
