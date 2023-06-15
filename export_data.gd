@tool
extends EditorScript

var data_path = "res://data"
var copy_path = "res://win_output/data"

func _run():
	var dir = DirAccess.open(data_path)
	dir.make_dir_recursive(copy_path)
	if dir != null:
		dir.list_dir_begin();
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				print("Copying " + file_name + " to /build-folder")
				dir.copy(data_path + "/" + file_name, copy_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
