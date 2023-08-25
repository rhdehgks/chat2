extends Node2D

@onready var _client : WebSocketClient = $WebSocketClient
@onready var _chat_log := $ChatUI/ChatLog
@onready var _line_edit := $ChatUI/LineEdit
var url := "ws://13.125.159.144:5000/chat"
#var url := "ws://127.0.0.1:8000/chat"
var id = ConfigManager.get_data("account", "id")
var nickname : String = ConfigManager.get_data("account", "nickname")
var is_registered := false

func _ready():
	print(nickname)
	is_registered = id != null
	var err = _client.connect_to_url(url)
	if err == OK:
		info("다음 서버와 연결 시도 (url: %s)" % url)
	else:
		info("연결에 실패하였습니다.")

func register(data):
	id = data['id']
	ConfigManager.set_data("account", "id", id)
	is_registered = true
	_client.send_data(data)

func info(msg):
	print(msg)
	_chat_log.text += msg + "\n"

func _on_web_socket_client_connected_to_server():
	info("연결되었습니다.")
	var data = {'id': id, 'nickname': nickname}
	_client.send_data(data)


func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	info("연결에 실패하였습니다. code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_web_socket_client_data_received(data):
	if is_registered:
		if data['id'] == id:
			info("[color=green]%s:[/color] %s" % [data['nickname'], data['msg']])
		else:
			info("%s: %s" % [data['nickname'], data['msg']])
	else:
		register(data)


func _on_send_button_pressed():
	if _line_edit.text == "":
		return
	var data = {'msg': _line_edit.text}
	_client.send_data(data)
	_line_edit.text = ""
