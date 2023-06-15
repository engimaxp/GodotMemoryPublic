extends "res://src/ui/switch_panel_base.gd"
@onready var file_dialog = $FileDialog

var file_dialog_state = 0
@onready var screen_shoot_line_edit = %ScreenShootLineEdit
@onready var language_option = %LanguageOption as OptionButton
@onready var default_panel_option = %DefaultPanelOption as OptionButton

const languages = ["zh_CN","en_US"]
const default_panels = [
	"Engine",
	"Proj",
	"Asset",
	"Tool",
	"Setting",
]

const language_dic = {
	"zh_CN":"中文",
	"en_US":"English",
}

func _ready():
	var ol = Global.config.get_value("Localization", "language", Global.config.default_language)
	for i in languages.size():
		language_option.add_item(language_dic[languages[i]])
		if ol == languages[i]:
			language_option.select(i)
	var od = Global.config.get_value("Setting", "DefaultPanel", "Engine") 
	for i in default_panels.size():
		default_panel_option.add_item(tr(default_panels[i]),i)
		if od == default_panels[i]:
			default_panel_option.select(i)
			
func _load_panel():
	screen_shoot_line_edit.text = Global.config.get_value("ImageScan","ScreenShootDir","")

func _on_screen_shot_directory_pressed():
	file_dialog_state = 0
	file_dialog.popup_centered()

func _on_file_dialog_dir_selected(dir):
	if file_dialog_state == 0:
		if DirAccess.dir_exists_absolute(dir):
			screen_shoot_line_edit.text = dir
			Global.config.set_value("ImageScan","ScreenShootDir",dir)

func _on_screen_shoot_line_edit_text_submitted(new_text):
	if not DirAccess.dir_exists_absolute(new_text):
		screen_shoot_line_edit.text = ""
	var dir = DirAccess.open(new_text)
	file_dialog_state = 0
	_on_file_dialog_dir_selected(dir.get_current_dir(true))


func _on_language_option_item_selected(index):
	Global.config.set_value("Localization", "language", languages[index])

func _on_default_panel_option_item_selected(index):
	Global.config.set_value("Setting", "DefaultPanel", default_panels[index]) 
