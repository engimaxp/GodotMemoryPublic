extends Node

@export var tag_type:Constants.TagType = Constants.TagType.Engine
@export var tag_sub_type:Constants.TagSubType = Constants.TagSubType.DEFAULT
const TagScene = preload("res://src/ui/tag.tscn")
@export var search_condition:Array[String]
@export var search_condition_nodepath:Array[NodePath]
@export var tag_tobe_selected_path:NodePath
@export var tag_selected_condition_path:NodePath
@export var tag_search_line_edit_nodepath:NodePath
@export var search_result_nodepath:Array[NodePath]
@export var tag_search_opt_menu_path:NodePath
@export var clear_search_node_path:NodePath
var search_condition_nodes = []
var search_result_nodes = []
@onready var tag_tobe_selected_node = get_node_or_null(tag_tobe_selected_path)
@onready var tag_selected_condition_node = get_node_or_null(tag_selected_condition_path)
@onready var tag_search_line_edit_node = get_node_or_null(tag_search_line_edit_nodepath) as LineEdit
@onready var tag_search_opt_menu_node = get_node_or_null(tag_search_opt_menu_path) as PopupMenu
@onready var clear_search_node = get_node_or_null(clear_search_node_path)
var search_conditions_dic = {}
var fast_tags = {}
var select_tag_ids = {}

signal condition_changed

func search_submit(new_string,ctl,index):
	ctl.text = ""
	search_conditions_dic[search_condition[index]] = new_string
	search_result_nodes[index].text = new_string
	condition_changed.emit()
	
func seach_tag_submit(new_tag_string):
	tag_search_line_edit_node.text = ""
	add_custom_search_tag(new_tag_string)
	
func add_custom_search_tag(new_tag_string):
	var exist = Db.QueryTagId(new_tag_string,tag_type,tag_sub_type)
	var ti
	if exist != null and not exist.is_empty():
		ti = exist
	else:
		return
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
	tag_selected_condition_node.add_child(t)
	condition_changed.emit()
	
@onready var txt_timer = $Timer

func search_tag_text_change(new_text:String):
	if not txt_timer.is_start:
		txt_timer.start()
		await txt_timer.timeout
		trigger_text_change()
	else:
		txt_timer.current_elasped_time = 0
		
func trigger_text_change():
	var new_text = tag_search_line_edit_node.text
	if new_text.length() == 0:
		return
	var exists = Db.QueryTagByNameLike(new_text,tag_type,tag_sub_type)
	if exists != null and not exists.is_empty():
		tag_search_opt_menu_node.clear()
		for x in exists:
			tag_search_opt_menu_node.add_item(x["Name"])
	else:
		tag_search_opt_menu_node.clear()
	tag_search_opt_menu_node.position = tag_search_line_edit_node.global_position +\
		Vector2(0,tag_search_line_edit_node.size.y)
	tag_search_opt_menu_node.popup()
	tag_search_opt_menu_node.size = Vector2(tag_search_line_edit_node.size.x,200)
	
func popup_index_pressed(index):
	var x = tag_search_opt_menu_node.get_item_text(index)
	add_custom_search_tag(x)
	tag_search_line_edit_node.text = ""

func clear_search():
	for c in search_result_nodes:
		c.text = ""
	search_conditions_dic.clear()
	condition_changed.emit()
	
func _ready():
	clear_search_node.pressed.connect(clear_search)
	tag_search_line_edit_node.text_submitted.connect\
		(seach_tag_submit)
	tag_search_line_edit_node.text_changed.connect\
		(search_tag_text_change)
	tag_search_opt_menu_node.index_pressed.connect(popup_index_pressed)
	var i = 0
	for x in search_condition_nodepath:
		var l = get_node_or_null(x) as LineEdit
		search_condition_nodes.append(l)
		l.text = ""
		l.text_submitted.connect(search_submit.bind(l,i))
		i += 1
	for x in search_result_nodepath:
		var l = get_node_or_null(x)
		l.text = ""
		search_result_nodes.append(l)
		
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
		tag_tobe_selected_node.add_child(t)
		t.pressed.connect(add_fast_tag_to_content.bind(t))

func tag_deleted(tag:Tag):
	select_tag_ids.erase(tag.id)
	if fast_tags.has(tag.text):
		fast_tags[tag.text].show()
		tag.queue_free()
	else:
		tag.queue_free()
	condition_changed.emit()
	
func add_fast_tag_to_content(tag:Tag):
	# check_tag_in_db_get_id
	if tag.id == null:
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
	tag_selected_condition_node.add_child(n)
	n.make_unique_panel_style()
	n.show()
	n.delete_pressed.connect(tag_deleted.bind(n))
	# new_tag_added
	select_tag_ids[tag.id] = 1
	condition_changed.emit()

func empty_condition()->bool:
	if tag_selected_condition_node.get_child_count() > 0:
		if tag_selected_condition_node.get_children().any(\
			func(x):return not x.is_queued_for_deletion()):
			return false
	for x in search_result_nodes:
		if x.text != "":
			return false
	return true
