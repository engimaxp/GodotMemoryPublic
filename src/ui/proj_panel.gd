extends "res://src/ui/switch_panel_base.gd"

@onready var add = %Add
const proj_row = preload("res://src/ui/proj_row.tscn")
@onready var v_box_container = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer
@onready var search_logic = %SerachLogic
@onready var found_num_label = %FoundNumLabel
@onready var swap_display = %SwapDisplay
@onready var page_container = %PageContainer

var page = {
	"index":1,
	"size":30
}
var popup_proj_edit

func _ready():
	popup_proj_edit = preload("res://src/ui/popup_proj_edit_menu.tscn").instantiate()
	get_tree().current_scene.call_deferred("add_child",popup_proj_edit)
	popup_proj_edit.hide()
	popup_proj_edit.refresh.connect(_load_panel)
	search_logic.condition_changed.connect(_load_panel)
	page_container.page_change.connect(page_change)

func page_change(index):
	page["index"] = index
	_load_panel()

func build_condition_from()->Array:
	var result = ["",""]
	if search_logic.search_conditions_dic.is_empty():
		result[0] = ""
	elif search_logic.search_conditions_dic.has("Search"):
		var s = search_logic.search_conditions_dic["Search"]
		result[0] = "(Name like '%%%s%%' or Version like '%%%s%%') and IsDelete = 0" % [s,s]
	
	if search_logic.select_tag_ids.is_empty():
		result[1] = ""
	else:
		var tags = "','".join(search_logic.select_tag_ids.keys())
		tags = "TagId in ('%s')" % tags
		result[1] = tags
	return result


func _load_panel():
	for c in v_box_container.get_children():
		c.queue_free()
	var total_result = Db.QueryAllCountFromDb("Proj")
	var projs
	if not search_logic.empty_condition():
		var condition = build_condition_from()
		var query_size = Db.QueryWithConditionCount(condition[0],condition[1],Constants.TagType.Proj)
		projs = Db.QueryWithConditionWithPage(condition[0],condition[1],Constants.TagType.Proj,page,true)
		found_num_label.text = "(%d/%d)" % [query_size,total_result]
		page_container.total_page = ceil(float(query_size) / float(page["size"]))
	else:
		projs = Db.QueryAllWithFromDBwithPage("Proj",page,true)
		found_num_label.text = "(%d/%d)" % [total_result,total_result]
		page_container.total_page = ceil(float(total_result) / float(page["size"]))
	for proj in projs:
		var e = proj_row.instantiate()
		e.proj_info = proj
		e.edit_pressed.connect(edit_pressed)
		e.refresh.connect(_load_panel)
		v_box_container.add_child(e)

func edit_pressed(dic,row):
	popup_proj_edit.proj_info = dic
	popup_proj_edit.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_add_pressed():
	popup_proj_edit.show()


func _on_swap_display_pressed():
	get_tree().call_group("ProjectRow","swap_display")

@onready var file_dialog = $FileDialog

func _on_scan_projects_pressed():
	file_dialog.popup_centered()

var scanned_proj = 0
var dup_scanned_proj = 0
var unsupport_scanned_proj = 0

func _on_file_dialog_dir_selected(dir):
	if not DirAccess.dir_exists_absolute(dir):
		return
	scanned_proj = 0
	dup_scanned_proj = 0
	unsupport_scanned_proj = 0
	scan_project_in(dir)
	Signals.ballon_pop.emit(tr("%d projects found, %d duplicated, %d unsupport")\
		 % [scanned_proj,dup_scanned_proj,unsupport_scanned_proj])

func scan_project_in(dir:String):
	var diracc = DirAccess.open(dir)
	for d in diracc.get_directories():
		var sp = dir + "/" + d
		if not FileAccess.file_exists(sp + "/project.godot"):
			scan_project_in(sp)
		else:
			make_project_from_dir(sp)
			scanned_proj += 1

func make_project_from_dir(path):
	var exist_projs = Db.QueryProjWithConditionFromDB("Directory = '%s' and IsDelete = 0" % path,"")
	if exist_projs != null and exist_projs.size() > 0:
		dup_scanned_proj += 1
		return
	else:
		print(path)
		if not FileAccess.file_exists(path + "/project.godot"):
			return
		var c = ConfigFile.new()
		c.load(path + "/project.godot")
		var v = c.get_value("","config_version",4)
		var main_version = 0
		var version
		if v == 4:
			main_version = 3
			version = "3.5"
		elif v == 5:
			var features = c.get_value("application","config/features",PackedStringArray(["4.0","FF"]))
			main_version = 4
			version = features[0]
		
		var proj_name = c.get_value("application","config/name","godot_project")
		
		var icon_file_path
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
		var engines = Db.QueryEngineWithConditionFromDB("MainVersion = %d and IsDefault = 1" % main_version,"")
		if engines == null or engines.is_empty():
			unsupport_scanned_proj += 1
			return
		var cf = Files.copy_to_cache(icon_file_path)
		var icon_id = cf[1]["Id"]
		Db.addProjInfo({
			"Version":version,
			"Directory":path,
			"Name":proj_name,
			"MainVersion":main_version,
			"Desc":"",
			"EngineId":engines[0]["Id"],
			"Icon":icon_id
		})
