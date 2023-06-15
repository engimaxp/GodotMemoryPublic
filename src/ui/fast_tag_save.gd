extends MarginContainer

@export var tag_type:Constants.TagType = Constants.TagType.Engine
@export var tag_sub_type:Constants.TagSubType = Constants.TagSubType.DEFAULT
@onready var subject_name = %SubjectName
@onready var fast_tag_logic = %FastTagLogic

# Called when the node enters the scene tree for the first time.
func _ready():
	var t = ""
	match tag_type:
		Constants.TagType.Engine:
			t = tr("Engine")
		Constants.TagType.Asset:
			t = tr("Asset")
		Constants.TagType.Tool:
			t = tr("Tool")
		Constants.TagType.Proj:
			t = tr("Proj")
	subject_name.text = t
	
	fast_tag_logic.tag_type = tag_type
	fast_tag_logic.tag_sub_type = tag_sub_type


