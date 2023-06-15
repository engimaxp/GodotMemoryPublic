extends Node
class_name CustomConfig

const config_file = "user://config.cfg"
var config

const default_language = "zh_CN"

func _ready():
	if not FileAccess.file_exists(config_file):
		init_file()
	else:
		load_file()
	
func init_file():
	# Create new ConfigFile object.
	config = ConfigFile.new()

	# Store some values.
#	config.set_value("Audio", "mute_all", false)
		
	config.set_value("Localization", "language", default_language)
	
	# Save it to a file (overwrite if already exists).
	config.save(config_file)

func load_file():
	config = ConfigFile.new()

	# Load data from a file.
	var err = config.load(config_file)
	for section in config.get_sections():
		for k in config.get_section_keys(section):
			var v = config.get_value(section,k)
			if v != null:
				var n = get_node_or_null(section)
				if is_instance_valid(n):
					n.set_value(k,v)
	# If the file didn't load, ignore it.
	if err != OK:
		print(err)
		
func get_value(section,key,default_value = null):
	return config.get_value(section,key,default_value)
	
func set_value(section,key,value):
	var n = get_node_or_null(section)
	if is_instance_valid(n):
		if n.set_value(key,value):
			config.set_value(section, key, value)
			config.save(config_file)
	else:
		config.set_value(section, key, value)
		config.save(config_file)

func refresh_help_all():
	config.save(config_file)

func change_language(target):
	var original = config.get_value("Localization", "language", default_language)
	if original == "en_US":
		target = "zh_CN"
	elif original == "zh_CN":
		target = "en_US"
	set_value("Localization", "language", target)
