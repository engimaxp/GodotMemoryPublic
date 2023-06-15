extends Node
const screen_shot_vault = "C:/Users/epevans/Pictures/"
const ImageContainer = preload("res://src/ui/image_container.tscn")

@onready var line_edit = %LineEdit
@onready var open_img = %OpenImg
@onready var file_dialog = %FileDialog
@onready var h_flow_container = $HFlowContainer

func _pop_dialog():
	file_dialog.current_path = screen_shot_vault
	file_dialog.popup_centered()

var unit_width = (float(1280 - (4 * 5) )/ 5.0)

func _ready():
	var now = Time.get_datetime_dict_from_system()
	var prefix = "%04d-%02d-%02d" % [now.year,now.month,now.day]
	var screen_shot_vault_dir = DirAccess.open(screen_shot_vault)
#	var possible_imgs = []
	var i = 0
	for f in screen_shot_vault_dir.get_files().slice(0,4):
		if f.begins_with("2021-11-26"):
			i += 1
#			possible_imgs.append(f)
			var t = ImageContainer.instantiate()
			var screen_shoot_file_path = screen_shot_vault + "/" + f
			t.texture = Utils.load_external_tex(screen_shoot_file_path)
			t.img_path = screen_shoot_file_path
			t.unit_width = unit_width
			t.index = i
			h_flow_container.add_child(t)
