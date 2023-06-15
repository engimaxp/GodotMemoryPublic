extends CanvasLayer
const ImageContainer = preload("res://src/ui/image_container.tscn")
var unit_width = (float(600 - (4 * 5) )/ 5.0)
@onready var scroll_container = %ScrollContainer
@onready var flow_container = %FlowContainer
var id
var ok_callback # Callable
var status = 0 # 0 drop file popup 1 click edit popup 2 scan pop up
var images:Array:
	set(val):
		images = val
		if is_inside_tree():
			for c in flow_container.get_children():
				c.queue_free()
			var i = 0
			for f in images:
				i += 1
	#			possible_imgs.append(f)
				var t = ImageContainer.instantiate()
				t.texture = f["image"]
				t.img_path = f["path"]
				if f.has("Id"):
					t.id = f["Id"]
				if f.has("select"):
					t.is_selected = f["select"]
				t.unit_width = unit_width
				t.index = i
				flow_container.add_child(t)

func get_selected_images()->Array:
	var result = []
	for c in flow_container.get_children():
		if c.is_selected:
			result.append({
				"image":c.texture,
				"path":c.img_path,
				"index":c.index
				})
	return result

func add_images(imgs_dic:Array):
	var i = flow_container.get_child_count()
	for f in imgs_dic:
		i += 1
#			possible_imgs.append(f)
		var t = ImageContainer.instantiate()
		t.texture = f["image"]
		t.img_path = f["path"]
		if f.has("Id"):
			t.id = f["Id"]
		if f.has("select"):
			t.is_selected = f["select"]
		t.unit_width = unit_width
		t.index = i
		flow_container.add_child(t)

func _ready():
	self.hide()

func _on_ok_pressed():
	ok_callback.call(get_selected_images(),status)
	self.hide()

func _on_cancel_pressed():
	self.hide()
