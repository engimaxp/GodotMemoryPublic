extends CanvasLayer
@onready var file_dialog = $FileDialog
var engine_info:Dictionary:
	set(val):
		engine_info = val
		if engine_info!=null and not engine_info.is_empty():
			if is_instance_valid(engine_exe_line_edit):
				refresh_widgets()

@onready var engine_exe_line_edit = %EngineExeLineEdit
@onready var main_version_line_edit = %MainVersionLineEdit
@onready var version_line_edit = %VersionLineEdit
@onready var console_line_edit = %ConsoleLineEdit
@onready var select_console_exe = %SelectConsoleExe
@onready var has_console_checkbox = %HasConsoleCheckbox as CheckBox
@onready var name_line_edit = %NameLineEdit
@onready var is_default_checkbox = %IsDefaultCheckbox
@onready var is_enc_check_box = %IsEncCheckBox
@onready var enc_key_line_edit = %EncKeyLineEdit
@onready var desc_edit = %DescEdit
@onready var tag_logic = %TagLogic

signal refresh


var file_dialog_state = 0 # 0 exe 1 console
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_pressed():
	self.hide()
	reset_all()

func reset_all():
	engine_info = {}
	version_line_edit.text = ""
	engine_exe_line_edit.text = ""
	is_enc_check_box.button_pressed = false
	enc_key_line_edit.text = ""
	has_console_checkbox.button_pressed = false
	console_line_edit.text = ""
	name_line_edit.text = ""
	is_default_checkbox.button_pressed = false
	main_version_line_edit.text = ""
	desc_edit.text = ""
	tag_logic.reset_data()

func refresh_widgets():
	version_line_edit.text = engine_info["Version"]
	engine_exe_line_edit.text = engine_info["Directory"]
	is_enc_check_box.button_pressed = bool(engine_info["IsEnc"])
	enc_key_line_edit.text = engine_info["EncKey"]
	has_console_checkbox.button_pressed = bool(engine_info["HasConsole"])
	console_line_edit.text = engine_info["ConsoleDir"]
	name_line_edit.text = engine_info["Name"]
	is_default_checkbox.button_pressed = bool(engine_info["IsDefault"])
	main_version_line_edit.text = str(engine_info["MainVersion"])
	desc_edit.text = engine_info["Desc"]
	var tags = Db.QueryTagNameByEngineId(engine_info["Id"])
	if tags!= null and not tags.is_empty():
		var tag_strings = []
		for t in tags:
			tag_strings.append(t["Name"])
		tag_logic.tag_info = tag_strings

func check_save()->bool:
	#todo 
	return true

func _on_ok_pressed():
	if not check_save():
		return
	var engine_id
	if engine_info == null or engine_info.is_empty():
		engine_id = Db.addEngineInfo({
			"Version":version_line_edit.text,
			"Directory":engine_exe_line_edit.text,
			"IsEnc":is_enc_check_box.button_pressed,
			"EncKey":enc_key_line_edit.text,
			"HasConsole":has_console_checkbox.button_pressed,
			"ConsoleDir":console_line_edit.text,
			"Name":name_line_edit.text,
			"IsDefault":is_default_checkbox.button_pressed,
			"MainVersion":main_version_line_edit.text,
			"Desc":desc_edit.text,
		})
		if not tag_logic.select_tag_ids.is_empty():
			Db.AddTagRelation(tag_logic.select_tag_ids,engine_id,Constants.TagType.Engine)
	else:
		engine_id = engine_info.Id
		Db.saveEngineInfo({
			"Id":engine_info.Id,
			"Version":version_line_edit.text,
			"Directory":engine_exe_line_edit.text,
			"IsEnc":is_enc_check_box.button_pressed,
			"EncKey":enc_key_line_edit.text,
			"HasConsole":has_console_checkbox.button_pressed,
			"ConsoleDir":console_line_edit.text,
			"Name":name_line_edit.text,
			"IsDefault":is_default_checkbox.button_pressed,
			"MainVersion":main_version_line_edit.text,
			"Desc":desc_edit.text,
		})
		Db.ReplaceTagRelation(tag_logic.select_tag_ids,engine_id,Constants.TagType.Engine)
	self.hide()
	reset_all()
	refresh.emit()

func _on_engine_executable_pressed():
	file_dialog_state = 0
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path:String):
	if file_dialog_state == 0:
		var exist_engines = Db.QueryEngineWithConditionFromDB("Directory = '%s'" % path,"")
		if exist_engines != null and exist_engines.size() > 0:
			reset_all()
			self.engine_info = exist_engines[0]
		else:
			engine_exe_line_edit.text = path
			var output = []
			var rt = OS.execute(path,["--version"],output,true)
			if rt >= 0:
				var version_txt = output[0] as String
				version_txt = version_txt.trim_suffix("\\r\\n")
				var version_arrays = version_txt.split(".") as PackedStringArray
				main_version_line_edit.text = version_arrays[0]
				version_line_edit.text = ".".join(version_arrays.slice(0,version_arrays.size() - 1))
			var console_app_addr = path.get_basename() + ".console." + path.get_extension()
			if FileAccess.file_exists(console_app_addr):
				has_console_checkbox.button_pressed = true
				console_line_edit.text = console_app_addr
			else:
				console_app_addr = path.get_basename() + "_console." + path.get_extension()
				if FileAccess.file_exists(console_app_addr):
					has_console_checkbox.button_pressed = true
					console_line_edit.text = console_app_addr

	elif file_dialog_state == 1:
		console_line_edit.text = path

func _on_select_console_exe_pressed():
	file_dialog_state = 1
	file_dialog.popup_centered()


func _on_engine_exe_line_edit_text_submitted(new_text):
	if not FileAccess.file_exists(new_text):
		engine_exe_line_edit.text = ""
		return
	var file = FileAccess.open(new_text,FileAccess.READ)
	new_text = file.get_path_absolute()
	file.close()
	_on_file_dialog_file_selected(new_text)
