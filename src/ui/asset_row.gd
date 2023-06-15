extends PanelContainer

const ImageContainer = preload("res://src/ui/image_container.tscn")

@onready var link_node = %Link
@onready var locate = %Locate
@onready var name_label = %AssetName
@onready var desc_node = %Desc
@onready var star = %star

@onready var run_button = %OpenLink
@onready var refresh_button = %RefreshStatus
@onready var edit_button = %Edit
@onready var open_dir_button = %OpenDir
@onready var star_button = %Star
@onready var delete_button = %Delete

@onready var asset_text_desc_container = %AssetTextDescContainer
@onready var asset_image_desc_container = %AssetImageDescContainer
@onready var copy_copy_right = %CopyCopyRight

const TagScene = preload("res://src/ui/tag.tscn")

signal edit_pressed(dic,from)
signal refresh

@onready var tag_container = %TagContainer

func swap_display():
	if asset_text_desc_container.visible:
		asset_text_desc_container.hide()
		asset_image_desc_container.show()
	else:
		asset_text_desc_container.show()
		asset_image_desc_container.hide()

var asset_info:Dictionary:
	set(val):
		asset_info = val
		if is_instance_valid(name_label):
			if asset_info["Star"]:
				star.show()
				star_button.toggle_value = true
			else:
				star.hide()
				star_button.toggle_value = false
			var desc = asset_info["Desc"]
			desc_node.text = desc
			
			name_label.text = asset_info["Name"]
			locate.text = asset_info["Directory"]
			if asset_info["Link"] != null and asset_info["Link"].length() > 0:
				run_button.disabled = false
				run_button.refresh()
				link_node.text = asset_info["Link"]
			else:
				run_button.disabled = true
				run_button.refresh()
				link_node.text = ""
#			for b in [run_button,refresh_button,edit_button\
#				,open_dir_button,star_button,delete_button]:
#					b.refresh()
			var tags = Db.QueryTagNameByRelateId(asset_info["Id"],Constants.TagType.Asset)
			
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
			var images = Db.QueryImagesByRelateId(asset_info["Id"],Constants.TagType.Asset)
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
					asset_image_desc_container.add_child(t)

func _ready():
	self.asset_info = asset_info

func _on_run_pressed():
	open_asset()
	
func open_asset():
	OS.shell_open(asset_info["Link"])

func _on_refresh_pressed():
	pass
	
func _on_edit_pressed():
	edit_pressed.emit(asset_info,self)

func _on_open_dir_pressed():
	OS.shell_open(str("file://", asset_info["Directory"]))

func _on_star_pressed():
	star_button.toggle_value = not star_button.toggle_value
	asset_info["Star"] = star_button.toggle_value
	Db.UpdateAssetStar(asset_info["Id"],asset_info["Star"])
	if asset_info["Star"]:
		star.show()
	else:
		star.hide()

func _on_delete_pressed():
	Signals.confirm_pop.emit(tr("Do you really want to delete [color=%s]%s[/color]?") % [Enums.red_color.to_html(),asset_info["Name"]],\
	func():
		Db.deleteAsset(asset_info["Id"])
		refresh.emit()
		)
		

func _on_copy_dir_pressed():
	DisplayServer.clipboard_set(asset_info["Directory"])
	Signals.ballon_pop.emit(tr("Asset Directory Copied To ClipBoard"))
	

func _on_copy_copy_right_pressed():
	DisplayServer.clipboard_set(asset_info["CopyRight"])
	Signals.ballon_pop.emit(tr("Asset CopyRight Copied To ClipBoard"))
	
