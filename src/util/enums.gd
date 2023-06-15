extends Node
class_name Constants
const UUID = preload("res://src/util/uuid.gd")

const white_color = Color("e1e1e1")
const green_color = Color(0.1558, 0.8672, 0.2003, 1)
const red_color =  Color(0.8594, 0.1578, 0.1578, 1)
const gray_shallow_color =  Color("79818c")
const gold_color =  Color("f8b44b")
const dark_blue_shallow_color =  Color("426287")
const dark_blue_color =  Color("15212f")

const godot3icon = preload("res://assest/icon/g867.png")
const godot4icon = preload("res://assest/icon/g866.png")

enum TagType {
	Engine = 0,
	Proj = 1,
	Asset = 2,
	Tool = 3
}

const TagMap = {
	TagType.Engine: "Engine",
	TagType.Proj: "Proj",
	TagType.Asset: "Asset",
	TagType.Tool: "Tool",
}

enum TagSubType {
	DEFAULT = 0
}
