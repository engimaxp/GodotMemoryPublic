extends Node

var mouse_clicked_means_select:= false
const ImagePopUp = preload("res://src/ui/image_preview_pop_up.tscn")
var current_img_preview_popup
var accept_image_drop = false
@onready var thread_pool = $ThreadPool as ThreadPool
@onready var config = $Config as CustomConfig

@onready var image_choose_window = $ImageChooseWindow

func _ready():
	var ol = Global.config.get_value("Localization", "language", Global.config.default_language)
	TranslationServer.set_locale(ol)
	get_viewport().files_dropped.connect(show_files)

func show_files(files):
	if not accept_image_drop:
		return
	var dic_array:Array[Dictionary] = []
	for x in files:
		var xfile = FileAccess.open(x,FileAccess.READ)
		var texture_e = Utils.load_external_tex(x)
		if texture_e == null:
			continue
		dic_array.append({
			"image":texture_e,
			"path":xfile.get_path_absolute()
		})
		xfile.close()
	if not dic_array.is_empty():
		image_choose_window.status = 0
		image_choose_window.images = dic_array
		image_choose_window.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func pop_up_image_preview(texture,pos):
	if is_instance_valid(current_img_preview_popup):
		if current_img_preview_popup.tex == texture:
			return
		current_img_preview_popup.queue_free()
	var img_popup = ImagePopUp.instantiate()
	img_popup.tex = texture
	img_popup.pos = pos
	current_img_preview_popup = img_popup
	self.add_child(img_popup)
	img_popup.popup()
