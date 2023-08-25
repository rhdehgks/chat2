extends Node2D

@onready var _line_edit := $MainUI/LineEdit
var chat_screen = preload("res://chat/chat.tscn")

func _ready():
	var name = ConfigManager.get_data("account", "nickname")
	if name:
		_line_edit.text = name

func _on_send_button_pressed():
	ConfigManager.set_data("account", "nickname", _line_edit.text)
	get_tree().change_scene_to_packed(chat_screen)
