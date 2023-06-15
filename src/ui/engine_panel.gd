extends "res://src/ui/switch_panel_base.gd"
@onready var add = %Add
const engine_row = preload("res://src/ui/engine_row.tscn")
@onready var v_box_container = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer
@onready var search_logic = %SerachLogic
@onready var found_num_label = %FoundNumLabel
@onready var page_container = %PageContainer

var page = {
	"index":1,
	"size":30
}
var popup_engine_edit
# Called when the node enters the scene tree for the first time.
func _ready():
	popup_engine_edit = preload("res://src/ui/popup_engine_edit_menu.tscn").instantiate()
	get_tree().current_scene.call_deferred("add_child",popup_engine_edit)
	popup_engine_edit.hide()
	popup_engine_edit.refresh.connect(_load_panel)
	search_logic.condition_changed.connect(_load_panel)
	page_container.page_change.connect(page_change)

func page_change(index):
	page["index"] = index
	_load_panel()

func build_condition_from()->Array:
	var result = ["",""]
	if search_logic.search_conditions_dic.is_empty():
		result[0] = ""
	elif search_logic.search_conditions_dic.has("Search"):
		var s = search_logic.search_conditions_dic["Search"]
		result[0] = "(Name like '%%%s%%' or Version like '%%%s%%') and IsDelete = 0" % [s,s]
	
	if search_logic.select_tag_ids.is_empty():
		result[1] = ""
	else:
		var tags = "','".join(search_logic.select_tag_ids.keys())
		tags = "TagId in ('%s')" % tags
		result[1] = tags
	return result


func _load_panel():
	for c in v_box_container.get_children():
		c.queue_free()
	var total_result = Db.QueryAllCountFromDb("Engine")
	var engines
	if not search_logic.empty_condition():
		var condition = build_condition_from()
		var query_size = Db.QueryWithConditionCount(condition[0],condition[1],Constants.TagType.Engine)
		engines = Db.QueryWithConditionWithPage(condition[0],condition[1],Constants.TagType.Engine,page,false)
		found_num_label.text = "(%d/%d)" % [query_size,total_result]
		page_container.total_page = ceil(float(query_size) / float(page["size"]))
	else:
		engines = Db.QueryAllWithFromDBwithPage("Engine",page,false)
		found_num_label.text = "(%d/%d)" % [total_result,total_result]
		page_container.total_page = ceil(float(total_result) / float(page["size"]))
	for engine in engines:
		var e = engine_row.instantiate()
		e.engine_info = engine
		e.edit_pressed.connect(edit_pressed)
		e.refresh.connect(_load_panel)
		v_box_container.add_child(e)

func edit_pressed(dic,row):
	popup_engine_edit.engine_info = dic
	popup_engine_edit.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_add_pressed():
	popup_engine_edit.show()
