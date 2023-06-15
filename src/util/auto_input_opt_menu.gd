extends PopupMenu

signal select_item(item_name)

@onready var button = $PanelContainer/ScrollContainer/Button
@onready var v_box_container = $PanelContainer/ScrollContainer/VBoxContainer
