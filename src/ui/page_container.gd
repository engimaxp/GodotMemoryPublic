extends HBoxContainer

signal page_change(page_index)
@onready var page_spin_box = $PageSpinBox

var total_page:int = 5:
	set(val):
		total_page = val
		if is_instance_valid(label):
			label.text = tr("pages (%d/%d)") % [page_spin_box.value,total_page]
			page_spin_box.max_value = total_page

@onready var label = $Label

func _on_page_spin_box_value_changed(value):
	value = clamp(value,1,total_page)
	page_spin_box.value = value
	page_change.emit(value)
	
