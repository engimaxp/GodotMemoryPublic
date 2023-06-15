extends Node
const ImageContainer = preload("res://src/ui/image_container.tscn")
@export var scan_button_path:NodePath
@export var add_drop_images_path:NodePath
@export var owner_path:NodePath
@export var added_images_path:NodePath

@onready var scan_button = get_node_or_null(scan_button_path)
@onready var add_drop_images = get_node_or_null(add_drop_images_path)
@onready var owner_node = get_node_or_null(owner_path)
@onready var added_images_container_node = get_node_or_null(added_images_path)
var unit_width = (float(400 - (4 * 5) )/ 5.0)
var screen_shot_vault

func reset_data():
	for c in added_images_container_node.get_children():
		c.queue_free()
	current_select_images_array.clear()
	
var current_select_images_array:Array = []:
	set(val):
		current_select_images_array = val
		if is_instance_valid(added_images_container_node):
			for c in added_images_container_node.get_children():
				c.queue_free()
			var i = 0
			for f in current_select_images_array:
				i += 1
				var t = ImageContainer.instantiate()
				t.texture = f["image"]
				t.img_path = f["path"]
				f["select"] = true
				if f.has("Id"):
					t.id = f["Id"]
				t.unit_width = unit_width
				t.index = i
				t.readonly = true
				added_images_container_node.add_child(t)

func _ready():
	screen_shot_vault = Global.config.get_value("ImageScan","ScreenShootDir","")
	scan_button.pressed.connect(scan_screen_shot_and_list)
	add_drop_images.gui_input.connect(pop_up_image_windows)

func bind_choose_window_callback():
	Global.image_choose_window.ok_callback = Callable(select_images)

func unbind_choose_window_callback():
	Global.image_choose_window.ok_callback = null
	
func select_images(imgs_dic,choose_state):
	var i
	if choose_state == 0 or choose_state == 2:
		i = added_images_container_node.get_child_count()
		for f in imgs_dic:
			if current_select_images_array.any(func(x):return x["path"] == f["path"]):
				continue
			i += 1
			var t = ImageContainer.instantiate()
			t.texture = f["image"]
			t.img_path = f["path"]
			f["select"] = true
			if f.has("Id"):
				t.id = f["Id"]
			current_select_images_array.append(f)
			t.unit_width = unit_width
			t.index = i
			t.readonly = true
			added_images_container_node.add_child(t)
	else:
		i = 0
		for c in added_images_container_node.get_children():
			c.queue_free()
			current_select_images_array.clear()
		for f in imgs_dic:
			i += 1
			var t = ImageContainer.instantiate()
			t.texture = f["image"]
			t.img_path = f["path"]
			f["select"] = true
			if f.has("Id"):
				t.id = f["Id"]
			current_select_images_array.append(f)
			t.unit_width = unit_width
			t.index = i
			t.readonly = true
			added_images_container_node.add_child(t)
		
func scan_screen_shot_and_list():
	var temps = []
	# proj directory
	var proj_directory = owner_node.get_project_dir()
	if proj_directory == null or proj_directory == "":
		return
	elif not DirAccess.dir_exists_absolute(proj_directory):
		return
	else:
		var pd = DirAccess.open(proj_directory)
		var i = 0
		for f in pd.get_files():
			if not Utils.is_image(f):
				continue
			i += 1
			temps.append({
				"image":Utils.load_external_tex(proj_directory + "/" + f),
				"path":proj_directory + "/" + f,
				"index":i
			})
	
	# screen shot directory
	if DirAccess.dir_exists_absolute(screen_shot_vault):
		var screen_shot_vault_dir = DirAccess.open(screen_shot_vault)
		var i = 0
		var now = Time.get_datetime_dict_from_system()
		var prefix = "%04d-%02d-%02d" % [now.year,now.month,now.day]
		for f in screen_shot_vault_dir.get_files():
			if f.begins_with(prefix):
				i += 1
				temps.append({
					"image":Utils.load_external_tex(screen_shot_vault + "/" + f),
					"path":screen_shot_vault + "/" + f,
				})
	
	if temps.size() == 0:
		return
	Global.image_choose_window.status = 2
	Global.image_choose_window.images = temps
	Global.image_choose_window.show()

func pop_up_image_windows(event):
	if event is InputEventMouseButton and event.is_pressed():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Global.image_choose_window.status = 1
			Global.image_choose_window.images = current_select_images_array
			Global.image_choose_window.show()
