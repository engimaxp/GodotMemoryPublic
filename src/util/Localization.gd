extends Node

func set_value(key,value)->bool:
	match key:
		"language":
			TranslationServer.set_locale(value)
			return true
	return false
