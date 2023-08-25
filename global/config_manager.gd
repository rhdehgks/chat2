extends Node

var config := ConfigFile.new()
var path := "user://data.cfg"

func _ready():
	config.load(path)

func get_data(section: String, key: String):
	return config.get_value(section, key)
	
func set_data(section: String, key: String, value: String):
	config.set_value(section, key, value)
	config.save(path)
