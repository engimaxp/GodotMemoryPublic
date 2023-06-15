extends Node

@export var tag_type:Constants.TagType = Constants.TagType.Engine
@export var tag_sub_type:Constants.TagSubType = Constants.TagSubType.DEFAULT

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
var tag_info = []:
	set(val):
		tag_info = val
		if is_instance_valid(tag_add_button):
			for c in tag_to_be_select.get_children():
				if c is Tag:
					fast_tags[c.text] = c
					if tag_info.has(c.text):
						c.hide()
			for c in tag_selected.get_children():
				c.queue_free()
			var tags_info = Db.QueryTags(tag_info,tag_type,tag_sub_type)
			for ti in tags_info:
				var t = TagScene.instantiate()
				t.text = ti["Name"]
				t.color = Color.from_string(ti["Color"],Color.WHITE)
				t.id = ti["Id"]
				select_tag_ids[ti["Id"]] = 1
				t.type = ti["Type"]
				t.sub_type = ti["SubType"]
				t.has_delete = true
				t.delete_pressed.connect(tag_deleted.bind(t))
				tag_selected.add_child(t)
		
var fast_tags = {}
var select_tag_ids = {}

func reset_data():
	select_tag_ids.clear()
	fast_tags.clear()
	tag_info.clear()
	for c in tag_selected.get_children():
		c.queue_free()
	for c in tag_to_be_select.get_children():
		if c is Tag:
			fast_tags[c.text] = c
			c.show()

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

	var fts = Db.QueryFastTags(tag_type,tag_sub_type)
	for ti in fts:
		var t = TagScene.instantiate()
		t.text = ti["Name"]
		t.color = Color.from_string(ti["Color"],Color.WHITE)
		t.id = ti["Id"]
		t.type = ti["Type"]
		t.sub_type = ti["SubType"]
		t.has_delete = false
		fast_tags[ti["Name"]] = t
		tag_to_be_select.add_child(t)
		tag_to_be_select.move_child(t,0)
		t.pressed.connect(add_fast_tag_to_content.bind(t))

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
	
	if fast_tags.has(new_tag_string):
		fast_tags[new_tag_string].hide()
		
	var t = TagScene.instantiate()
	t.text = ti["Name"]
	t.color = Color.from_string(ti["Color"],Color.WHITE)
	t.id = ti["Id"]
	select_tag_ids[ti["Id"]] = 1
	t.type = ti["Type"]
	t.sub_type = ti["SubType"]
	t.has_delete = true
	t.delete_pressed.connect(tag_deleted.bind(t))
	tag_selected.add_child(t)
	
func add_fast_tag_to_content(tag:Tag):
	# check_tag_in_db_get_id
	if tag.id == null || tag.id.length() == 0:
		var result = Db.QueryTagId(tag.text,tag.type,tag.sub_type)
		if result == null or result.size() == 0:
			result = Db.InsertTag(tag.text,tag.color.to_html(false),tag.type,tag.sub_type)
		tag.id = result["Id"]
	# origin_tag.hide()
	tag.refresh()
	tag.hide()
	# new_tag_with_uuid() add to selected
	var n = tag.duplicate() as Tag
	n.has_delete = true
	tag_selected.add_child(n)
	n.make_unique_panel_style()
	n.show()
	n.delete_pressed.connect(tag_deleted.bind(n))
	# new_tag_added
	select_tag_ids[tag.id] = 1

func tag_deleted(tag:Tag):
	select_tag_ids.erase(tag.id)
	if fast_tags.has(tag.text):
		fast_tags[tag.text].show()
		tag.queue_free()
	else:
		tag.queue_free()
