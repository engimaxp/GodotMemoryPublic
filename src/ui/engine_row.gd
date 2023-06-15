extends PanelContainer

@onready var version = %Version
@onready var locate = %Locate
@onready var name_label = %Name
@onready var icon = %Icon

@onready var run_button = %Run
@onready var console_button = %Console
@onready var edit_button = %Edit
@onready var open_dir_button = %OpenDir
@onready var copy_encryption_button = %CopyEncryption
@onready var delete_button = %Delete

const TagScene = preload("res://src/ui/tag.tscn")

signal edit_pressed(dic,from)
signal refresh
@onready var tag_container = %TagContainer

var engine_info:Dictionary:
	set(val):
		engine_info = val
		if is_instance_valid(name_label):
			var desc = engine_info["Desc"]
			if desc != null and desc.length() > 0:
				icon.tooltip_text = desc
			if engine_info["MainVersion"] == 3:
				icon.texture = Constants.godot3icon
			else:
				icon.texture = Constants.godot4icon
			name_label.text = engine_info["Name"]
			locate.text = engine_info["Directory"]
			version.text = engine_info["Version"]
			if not bool(engine_info["HasConsole"]):
				console_button.disabled = true
			if not bool(engine_info["IsEnc"]):
				copy_encryption_button.disabled = true
			for b in [run_button,console_button,edit_button\
				,open_dir_button,copy_encryption_button,delete_button]:
					b.refresh()
			var tags = Db.QueryTagNameByEngineId(engine_info["Id"])
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

# Called when the node enters the scene tree for the first time.
func _ready():
	self.engine_info = engine_info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_mouse_entered():
	pass # Replace with function body.


func _on_run_pressed():
	print(engine_info["ConsoleDir"])
	OS.create_process(engine_info["Directory"],["-p"])


func _on_console_pressed():
	print(engine_info["ConsoleDir"])
	OS.create_process(engine_info["ConsoleDir"],["-p"],true)

func _on_edit_pressed():
	edit_pressed.emit(engine_info,self)

func _on_open_dir_pressed():
	OS.shell_open(str("file://", (engine_info["Directory"] as String).get_base_dir()))

func _on_copy_encryption_pressed():
	DisplayServer.clipboard_set(engine_info["EncKey"])
	Signals.ballon_pop.emit(tr("Encrypt Key Copied To ClipBoard"))
	
func _on_delete_pressed():
	Signals.confirm_pop.emit(tr("Do you really want to delete [color=%s]%s[/color]?") % [Enums.red_color.to_html(),engine_info["Name"]],\
	func():
		Db.deleteEngine(engine_info["Id"])
		refresh.emit()
		)
	
	
