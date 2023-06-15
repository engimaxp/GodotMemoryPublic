extends Node

func LoadImageFromDic(dic) -> ImageTexture:
	var width = dic["Width"]
	var height = dic["Height"]
	var format = dic["Format"]
	var path = dic["Path"]
	var n_path = dic["NewPath"]
	var img = load_external_tex(n_path)
	return img

func is_image(path):
	if path.ends_with(".png") || path.ends_with(".PNG"):
		return true
	elif path.ends_with(".jpg") || path.ends_with(".jpeg") || path.ends_with(".JPG") || path.ends_with(".JPEG"):
		return true
	elif path.ends_with(".webp") || path.ends_with(".WEBP"):
		return true
	elif path.ends_with(".bmp") || path.ends_with(".BMP"):
		return true
	elif path.ends_with(".svg") || path.ends_with(".SVG"):
		return true
	else:
		return false
		
func load_external_tex(path) -> ImageTexture:
	# credits and thanks to u/golddotasksquestions over on Reddit
	var bytes = FileAccess.get_file_as_bytes(path)
	var img = Image.new()
	if path.ends_with(".png") || path.ends_with(".PNG"):
		# warning-ignore:unused_variable
		var error = img.load_png_from_buffer(bytes)
		if error != OK:
			print(error)
	elif path.ends_with(".jpg") || path.ends_with(".jpeg") || path.ends_with(".JPG") || path.ends_with(".JPEG"):
		# warning-ignore:unused_variable
		var data = img.load_jpg_from_buffer(bytes)
	elif path.ends_with(".webp") || path.ends_with(".WEBP"):
		# warning-ignore:unused_variable
		var data = img.load_webp_from_buffer(bytes)
	elif path.ends_with(".bmp") || path.ends_with(".BMP"):
		# warning-ignore:unused_variable
		var data = img.load_bmp_from_buffer(bytes)
	elif path.ends_with(".svg") || path.ends_with(".SVG"):
		# warning-ignore:unused_variable
		img = Image.load_from_file(path)
	else:
		return null
	var imgtex = ImageTexture.create_from_image(img)
	return imgtex
	
