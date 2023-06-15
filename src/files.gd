extends Node

const UUID = preload("res://src/util/uuid.gd")

#var test_file = "res://data/test.txt"
#var packed_array = PackedStringArray()

const img_cache_dir = "res://data/cache/img"

## return 0 image texture 1 db dic 
func copy_to_cache(imgpath:String) -> Array:
	var img = Utils.load_external_tex(imgpath)
	var path2 = img_cache_dir + "/" + imgpath.get_file()
	if FileAccess.file_exists(path2):
		if FileAccess.get_md5(path2) == FileAccess.get_md5(imgpath):
			pass
		else:
			var file_name = imgpath.get_file().trim_suffix("." + imgpath.get_extension())
			path2 = "%s/%s%s.%s" % [img_cache_dir,file_name,UUID.v4(),imgpath.get_extension()]
			DirAccess.copy_absolute(imgpath,path2)
	else:
		DirAccess.copy_absolute(imgpath,path2)
	var dic = Db.saveTextureToDB(img,imgpath,path2)
	return [img,dic]

func AddImageRelation(image_dics,relateid,type):
	for img_dic in image_dics:
		var r = copy_to_cache(img_dic["path"])
		Db.AddImageRelation(r[1]["Id"],relateid,type)

func ReplaceImageRelation(image_dics,relateid,type):
	Db.DeleteImageRelation(relateid,type)
	for x in image_dics:
		if x.has("Id"):
			Db.AddImageRelation(x["Id"],relateid,type)
		else:
			var r = copy_to_cache(x["path"])
			Db.AddImageRelation(r[1]["Id"],relateid,type)

#func _ready():
#	print("res://asd/icon.svg".trim_prefix("res://").get_base_dir())
#	var t_start = Time.get_ticks_usec()
#	randomize()
#	for i in 10000:
#		var x = UUID.v4()
#		if packed_array.find(x) > -1:
#			printerr("dup")
#			break
#		packed_array.append(x)
#	var t_end = Time.get_ticks_usec()
#	print("used %.2f ms" %( (t_end - t_start)/1000.0))

#	var unix_time = FileAccess.get_modified_time(ProjectSettings.globalize_path(test_file))
#	var time = Time.get_datetime_string_from_unix_time(unix_time)
#	var time2 = Time.get_datetime_string_from_system(true)
#	print(time)
#	print(time2)
