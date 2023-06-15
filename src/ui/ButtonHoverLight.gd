extends TextureButton

@export var is_toggle = false
var toggle_value = false:
	set(val):
		toggle_value = val
		if is_inside_tree():
			if toggle_value:
				self.material.set("shader_parameter/tint_color",Enums.gold_color)
			else:
				self.material.set("shader_parameter/tint_color",Enums.dark_blue_shallow_color)

func _ready():
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)

func refresh():
	if disabled:
		self.material.set("shader_parameter/tint_color",Enums.gray_shallow_color)

func _on_mouse_entered():
	if is_toggle and toggle_value:
		return
	if not disabled:
		self.material.set("shader_parameter/tint_color",Enums.gold_color)

func _on_mouse_exited():
	if is_toggle and toggle_value:
		return
	if not disabled:
		self.material.set("shader_parameter/tint_color",Enums.dark_blue_shallow_color)
