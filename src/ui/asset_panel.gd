extends "res://src/ui/switch_panel_base.gd"

@onready var add = %Add
const asset_row = preload("res://src/ui/asset_row.tscn")
@onready var v_box_container = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer
@onready var search_logic = %SerachLogic
@onready var found_num_label = %FoundNumLabel
@onready var swap_display = %SwapDisplay
@onready var page_container = %PageContainer

var page = {
	"index":1,
	"size":30
}
var popup_asset_edit

func _ready():
	popup_asset_edit = preload("res://src/ui/popup_asset_edit_menu.tscn").instantiate()
	get_tree().current_scene.call_deferred("add_child",popup_asset_edit)
	popup_asset_edit.hide()
	popup_asset_edit.refresh.connect(_load_panel)
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
		result[0] = "(Name like '%%%s%%' or Desc like '%%%s%%' or Link like '%%%s%%' or CopyRight like '%%%s%%') and IsDelete = 0"\
		 % [s,s,s,s]
	
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
	var total_result = Db.QueryAllCountFromDb("Asset")
	var assets
	if not search_logic.empty_condition():
		var condition = build_condition_from()
		var query_size = Db.QueryWithConditionCount(condition[0],condition[1],Constants.TagType.Asset)
		assets = Db.QueryWithConditionWithPage(condition[0],condition[1],Constants.TagType.Asset,page,true)
		found_num_label.text = "(%d/%d)" % [query_size,total_result]
		page_container.total_page = ceil(float(query_size) / float(page["size"]))
	else:
		assets = Db.QueryAllWithFromDBwithPage("Asset",page,true)
		found_num_label.text = "(%d/%d)" % [total_result,total_result]
		page_container.total_page = ceil(float(total_result) / float(page["size"]))
	for asset in assets:
		var e = asset_row.instantiate()
		e.asset_info = asset
		e.edit_pressed.connect(edit_pressed)
		e.refresh.connect(_load_panel)
		v_box_container.add_child(e)

func edit_pressed(dic,row):
	popup_asset_edit.asset_info = dic
	popup_asset_edit.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_add_pressed():
	popup_asset_edit.show()


func _on_swap_display_pressed():
	get_tree().call_group("AssetRow","swap_display")
