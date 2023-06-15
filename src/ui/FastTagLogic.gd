extends Node

@export var tag_sub_type:Constants.TagSubType = Constants.TagSubType.DEFAULT
@export var tag_type:Constants.TagType = Constants.TagType.Engine:
	set(val):
		tag_type = val
		if is_instance_valid(tag_add_button):
			for c in tag_selected.get_children():
				c.queue_free()
			var tags_info = Db.QueryFastTags(tag_type,tag_sub_type)
			for ti in tags_info:
				var t = TagScene.instantiate()
				t.text = ti["Name"]
				t.color = Color.from_string(ti["Color"],Color.WHITE)
				t.id = ti["Id"]
				t.type = ti["Type"]
				t.sub_type = ti["SubType"]
				t.has_delete = true
				t.delete_pressed.connect(tag_deleted.bind(t))
				tag_selected.add_child(t)

@export var tag_to_be_select_nodepath:NodePath
@export var tag_line_edit_nodepath:NodePath
@export var tag_add_button_nodepath:NodePath
@export var tag_selected_nodepath:NodePath
@onready var tag_to_be_select = get_node_or_null(tag_to_be_select_nodepath)
@onready var tag_line_edit = get_node_or_null(tag_line_edit_nodepath)
@onready var tag_add_button = get_node_or_null(tag_add_button_nodepath)
@onready var tag_selected = get_node_or_null(tag_selected_nodepath)
@export var tag_search_opt_menu_path:NodePath
@onready var tag_search_opt_menu_node = get_node_or_null(tag_search_opt_menu_path) as PopupMenu
const TagScene = preload("res://src/ui/tag.tscn")


func reset_data():
	for c in tag_selected.get_children():
		c.queue_free()

@onready var txt_timer = $Timer

func search_tag_text_change(new_text:String):
	if not txt_timer.is_start:
		txt_timer.start()
		await txt_timer.timeout
		trigger_text_change()
	else:
		txt_timer.current_elasped_time = 0
		
func trigger_text_change():
	var new_text = tag_line_edit.text
	if new_text.length() == 0:
		return
	var exists = Db.QueryTagByNameLike(new_text,tag_type,tag_sub_type)
	if exists != null and not exists.is_empty():
		tag_search_opt_menu_node.clear()
		for x in exists:
			tag_search_opt_menu_node.add_item(x["Name"])
	else:
		tag_search_opt_menu_node.clear()
	tag_search_opt_menu_node.position = tag_line_edit.global_position +\
		Vector2(0,tag_line_edit.size.y)
	tag_search_opt_menu_node.popup()
	tag_search_opt_menu_node.size = Vector2(tag_line_edit.size.x,100)

func popup_index_pressed(index):
	var x = tag_search_opt_menu_node.get_item_text(index)
	add_custom_tag(x)
	tag_line_edit.text = ""

func custom_tag_submit(new_text):
	tag_line_edit.text = ""
	add_custom_tag(new_text)

func _ready():
	tag_line_edit.text_submitted.connect\
		(custom_tag_submit)
	tag_line_edit.text_changed.connect\
		(search_tag_text_change)
	tag_search_opt_menu_node.index_pressed.connect(popup_index_pressed)
	tag_add_button.pressed.connect(add_tag_press)
	
func add_tag_press():
	var new_tag_string = tag_line_edit.text
	tag_line_edit.text = ""
	add_custom_tag(new_tag_string)
	
func add_custom_tag(new_tag_string):
	var exist = Db.QueryTagId(new_tag_string,tag_type,tag_sub_type)
	var ti
	if exist != null and not exist.is_empty():
		ti = exist
	else:
		var rand_color = Color(randf(),randf(),randf())
		ti = Db.InsertTag(new_tag_string,rand_color.to_html(false),tag_type,tag_sub_type)
	if tag_selected.get_children().any(func(x): 
			return false if (x == null or x.is_queued_for_deletion()) \
			else (x.text == new_tag_string)):
		return
	var t = TagScene.instantiate()
	t.text = ti["Name"]
	t.color = Color.from_string(ti["Color"],Color.WHITE)
	t.id = ti["Id"]
	t.type = ti["Type"]
	t.sub_type = ti["SubType"]
	t.has_delete = true
	t.delete_pressed.connect(tag_deleted.bind(t))
	tag_selected.add_child(t)
	Db.SetFastTag(t.id,true)
	
	
func tag_deleted(tag:Tag):
	Db.SetFastTag(tag.id,false)
	tag.queue_free()
