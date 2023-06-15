extends Node
const UUID = preload("res://src/util/uuid.gd")

const db_file_name = "res://data/GodotMemory.db"
var db

func _ready():
	db = SQLite.new()
	db.path = db_file_name
	db.open_db()

func QueryTags(tag_info,tag_type,tag_sub_type):
	if tag_info == null or tag_info.is_empty():
		return []
	db.query("select * from Tag where Name in ('%s') and Type = %d and SubType = %d"\
		 % ["','".join(tag_info),tag_type,tag_sub_type])
	var result = db.query_result
	return result

func QueryFastTags(tag_type,tag_sub_type):
	db.query("select * from Tag where IsFast = 1 and Type = %d and SubType = %d"\
		 % [tag_type,tag_sub_type])
	var result = db.query_result
	return result

func AddTagRelation(select_tag_ids,engine_id,type):
	for id in select_tag_ids:
		db.insert_row("TagRelation",{
			"TagId":id,
			"RelateId":engine_id,
			"Type":type
		})

func ReplaceTagRelation(select_tag_ids,engine_id,type):
	db.delete_rows("TagRelation","RelateId = '%s' and Type = %d" % \
		[engine_id,type])
	for id in select_tag_ids:
		db.insert_row("TagRelation",{
			"TagId":id,
			"RelateId":engine_id,
			"Type":type
		})

func AddImageRelation(image_id,relateid,type):
	db.insert_row("ImageRelation",{
		"ImageId":image_id,
		"RelateId":relateid,
		"Type":type
	})

func DeleteImageRelation(relateid,type):
	db.delete_rows("ImageRelation","RelateId = '%s' and Type = %d" % \
		[relateid,type])

func QueryTagNameByEngineId(engine_id):
	db.query("select Tag.* from Tag join TagRelation \
	on Tag.Id = TagRelation.TagId and TagRelation.type = 0\
	and TagRelation.RelateId = '%s'\
	" % [engine_id])
	var result = db.query_result
	return result

func QueryTagNameByProjId(proj_id):
	db.query("select Tag.* from Tag join TagRelation \
	on Tag.Id = TagRelation.TagId and TagRelation.type = 1\
	and TagRelation.RelateId = '%s'\
	" % [proj_id])
	var result = db.query_result
	return result

func QueryTagNameByRelateId(relateId,type):
	db.query("select Tag.* from Tag join TagRelation \
	on Tag.Id = TagRelation.TagId and TagRelation.type = %d\
	and TagRelation.RelateId = '%s'\
	" % [type,relateId])
	var result = db.query_result
	return result

func QueryImagesByRelateId(relateId,type):
	db.query("select Images.* from Images join ImageRelation \
	on Images.Id = ImageRelation.ImageId and ImageRelation.type = %d\
	and ImageRelation.RelateId = '%s'\
	" % [type,relateId])
	var result = db.query_result
	return result
	
func QueryTagId(text,type,sub_type):
	db.query("select * from Tag where Name = '%s' and Type = %d and SubType = %d limit 1" % [text,type,sub_type])
	var result = db.query_result
	if result == null or result.size() == 0:
		return null
	return result[0]

func QueryTagByNameLike(text,type,sub_type):
	db.query("select * from Tag where Name like '%%%s%%' and Type = %d and SubType = %d" % [text,type,sub_type])
	var result = db.query_result
	if result == null or result.size() == 0:
		return null
	return result

func InsertTag(text,color,type,sub_type):
	var idata = {}
	idata["Id"] = UUID.v4()
	idata["Name"] = text
	idata["Color"] = color
	idata["Type"] = type
	idata["SubType"] = sub_type
	db.insert_row("Tag",idata)
	return idata

func addEngineInfo(idata):
	idata["Sort"] = QueryMaxSort("Engine") + 1
	idata["Id"] = UUID.v4()
	idata["IsDelete"] = false
	db.insert_row("Engine",idata)
	return idata["Id"]
	
func saveEngineInfo(idata):
	var id = idata["Id"]
	idata.erase("Id")
	var e = db.update_rows("Engine","Id = '%s'" % id,idata)

func addProjInfo(idata):
	idata["Sort"] = QueryMaxSort("Proj") + 1
	idata["Id"] = UUID.v4()
	idata["Star"] = false
	idata["IsDelete"] = false
	db.insert_row("Proj",idata)
	return idata["Id"]
	
func saveProjInfo(idata):
	var id = idata["Id"]
	idata.erase("Id")
	var e = db.update_rows("Proj","Id = '%s'" % id,idata)

func addAssetInfo(idata):
	idata["Sort"] = QueryMaxSort("Asset") + 1
	idata["Id"] = UUID.v4()
	idata["Star"] = false
	idata["IsDelete"] = false
	db.insert_row("Asset",idata)
	return idata["Id"]
	
func saveAssetInfo(idata):
	var id = idata["Id"]
	idata.erase("Id")
	var e = db.update_rows("Asset","Id = '%s'" % id,idata)

func addToolInfo(idata):
	idata["Sort"] = QueryMaxSort("Tool") + 1
	idata["Id"] = UUID.v4()
	idata["Star"] = false
	idata["IsDelete"] = false
	db.insert_row("Tool",idata)
	return idata["Id"]
	
func saveToolInfo(idata):
	var id = idata["Id"]
	idata.erase("Id")
	var e = db.update_rows("Tool","Id = '%s'" % id,idata)

func UpdateProjStar(id,star):
	var e = db.update_rows("Proj","Id = '%s'" % id,{"Star":star})

func UpdateAssetStar(id,star):
	var e = db.update_rows("Asset","Id = '%s'" % id,{"Star":star})

func UpdateToolStar(id,star):
	var e = db.update_rows("Tool","Id = '%s'" % id,{"Star":star})

func SetFastTag(id,fast):
	var e = db.update_rows("Tag","Id = '%s'" % id,{"IsFast":fast})

func UpdateTagColor(id,color):
	var e = db.update_rows("Tag","Id = '%s'" % id,{"Color":color})

func deleteEngine(id):
	var e = db.update_rows("Engine","Id = '%s'" % id,{"IsDelete":true})
#	db.delete_rows("Engine","Id = '%s'" % id)
	
func deleteProj(id):
	var e = db.update_rows("Proj","Id = '%s'" % id,{"IsDelete":true})
#	db.delete_rows("Proj","Id = '%s'" % id)
	
func deleteAsset(id):
	var e = db.update_rows("Asset","Id = '%s'" % id,{"IsDelete":true})
#	db.delete_rows("Proj","Id = '%s'" % id)
	
func deleteTool(id):
	var e = db.update_rows("Tool","Id = '%s'" % id,{"IsDelete":true})
#	db.delete_rows("Proj","Id = '%s'" % id)
	
func QueryMaxSort(table_name)->int:
	db.query("select max(Sort) as sort from %s where IsDelete = 0" % table_name)
	var result = db.query_result
	if result == null or result.size() == 0 or result[0]["sort"] == null:
		return 0
	return int(result[0]["sort"])
	
func QueryAllEngineFromDB():
	db.query("select * from Engine where IsDelete = 0 order by sort desc")
	var result = db.query_result
	return result

func QueryAllProjFromDB():
	db.query("select * from Proj where IsDelete = 0 order by star desc, sort desc")
	var result = db.query_result
	return result

func QueryAllCountFromDb(table_name):
	db.query("select count(Id) as count from %s where IsDelete = 0" % table_name)
	var result = db.query_result
	if result == null or result.size() == 0 or result[0]["count"] == null:
		return 0
	return int(result[0]["count"])

func QueryAllAssetFromDB():
	db.query("select * from Asset where IsDelete = 0 order by star desc, sort desc")
	var result = db.query_result
	return result

func QueryAllToolFromDB():
	db.query("select * from Tool where IsDelete = 0 order by star desc, sort desc")
	var result = db.query_result
	return result


func normal_and_query(condition):
	if condition == null or condition.length() == 0:
		condition = ""
	else:
		condition = " and " + condition
	return condition

func QueryWithConditionCount(condition,tag_condition,tag_type):
	tag_condition = normal_and_query(tag_condition)
	var table_name = Constants.TagMap[tag_type]
	var s
	if tag_condition == "":
		s = "select count(Id) as count from %s e where\
 		 %s " % \
		[table_name,condition]
	else:
		condition = normal_and_query(condition)
		s = "select count(Id) as count from %s e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s " % \
		[table_name,tag_type,tag_condition,condition]
	db.query(s)
	var result = db.query_result
	if result == null or result.size() == 0 or result[0]["count"] == null:
		return 0
	return int(result[0]["count"])

func QueryAllWithFromDBwithPage(table_name,page,has_star):
	db.query("select * from %s where IsDelete = 0 order by %s sort desc LIMIT %d OFFSET %d"\
	% [table_name,"star desc," if has_star else ""\
	,page["size"],(page["index"] - 1) * page["size"]]
	)
	var result = db.query_result
	return result

func QueryWithConditionWithPage(condition,tag_condition,tag_type,page,has_star):
	tag_condition = normal_and_query(tag_condition)
	var table_name = Constants.TagMap[tag_type]
	var s
	if tag_condition == "":
		s = "select * from %s e where\
 		 %s order by %s Sort desc LIMIT %d OFFSET %d" % \
		[table_name,condition,\
		"star desc," if has_star else "",\
		page["size"],(page["index"] - 1) * page["size"]
		]
	else:
		condition = normal_and_query(condition)
		s = "select * from %s e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s order by %s Sort desc LIMIT %d OFFSET %d" % \
		[table_name,tag_type,tag_condition,condition,\
		"star desc," if has_star else "",\
		page["size"],(page["index"] - 1) * page["size"]]
	print(s)
	db.query(s)
	var result = db.query_result
	return result

func QueryProjWithConditionFromDB(condition,tag_condition):
	tag_condition = normal_and_query(tag_condition)
	var s
	if tag_condition == "":
		s = "select * from Proj e where\
 		 %s order by star desc, Sort desc" % \
		[condition]
	else:
		condition = normal_and_query(condition)
		s = "select * from Proj e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s order by  star desc,Sort desc" % \
		[Constants.TagType.Proj,tag_condition,condition]
	db.query(s)
	var result = db.query_result
	return result

func QueryAssetWithConditionFromDB(condition,tag_condition):
	tag_condition = normal_and_query(tag_condition)
	var s
	if tag_condition == "":
		s = "select * from Asset e where\
 		 %s order by star desc, Sort desc" % \
		[condition]
	else:
		condition = normal_and_query(condition)
		s = "select * from Asset e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s order by star desc, Sort desc" % \
		[Constants.TagType.Asset,tag_condition,condition]
	db.query(s)
	var result = db.query_result
	return result

func QueryToolWithConditionFromDB(condition,tag_condition):
	tag_condition = normal_and_query(tag_condition)
	var s
	if tag_condition == "":
		s = "select * from Tool e where\
 		 %s order by star desc, Sort desc" % \
		[condition]
	else:
		condition = normal_and_query(condition)
		s = "select * from Tool e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s order by star desc, Sort desc" % \
		[Constants.TagType.Tool,tag_condition,condition]
	db.query(s)
	var result = db.query_result
	return result

func QueryEngineWithConditionFromDB(condition,tag_condition):
	tag_condition = normal_and_query(tag_condition)
	var s
	if tag_condition == "":
		s = "select * from Engine e where\
 		 %s  order by Sort desc" % \
		[condition]
	else:
		condition = normal_and_query(condition)
		s = "select * from Engine e where\
 		exists(select 1 from TagRelation where Type = %d and RelateId = e.Id %s) %s   order by Sort desc" % \
		[Constants.TagType.Engine,tag_condition,condition]
#	print(s)
	db.query(s)
	var result = db.query_result
	return result

func GetEngineById(id):
	var s = "select * from Engine where Id = '%s' limit 1" % id
	db.query(s)
	var result = db.query_result
	if result == null or result.size() == 0:
		return null
	return result[0]

func saveTextureToDB(texture:ImageTexture,imgpath:String,new_path:String):
	var img = texture.get_image() as Image
	var idata = {
		"Id": UUID.v4(),
		"Width": img.get_width(),
		"Height": img.get_height(),
		"Format": img.get_height(),
		"Path":imgpath,
		"NewPath":new_path
		}
	db.insert_row("Images",idata)
	return idata

func LoadImageFromDB(id):
	db.query("select * from Images where Id = \"%s\" limit 1" % id)
	return [Utils.LoadImageFromDic(db.query_result[0]),db.query_result[0]]

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		db.close_db()
		get_tree().quit() # default behavior

func QueryImagesByRID(relateid:String,type:int):
	db.query("select Images.* from Images join ImageRelation \
	on Images.Id = ImageRelation.ImageId and ImageRelation.type = %d\
	and TagRelation.RelateId = '%s'\
	" % [type,relateid])
	var result = db.query_result
	return result

func AddImagesRelation(select_tag_ids,relateid,type):
	for id in select_tag_ids:
		db.insert_row("TagRelation",{
			"TagId":id,
			"RelateId":relateid,
			"Type":type
		})

func ReplaceImagesRelation(select_tag_ids,relateid,type):
	db.delete_rows("TagRelation","RelateId = '%s' and Type = %d" % \
		[relateid,type])
	AddImagesRelation(select_tag_ids,relateid,type)
