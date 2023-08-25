extends Node2D
class_name WebSocketClient

var socket = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED

signal connected_to_server()
signal connection_closed()
signal data_received(data: Variant)

func connect_to_url(url) -> int:
	var err = socket.connect_to_url(url)
	if err != OK:
		return err
	last_state = socket.get_ready_state()
	return OK


func send_data(data) -> int:
	if typeof(data) == TYPE_DICTIONARY:
		return socket.send_text(JSON.stringify(data))
	return socket.send(var_to_bytes(data))


func get_data() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var packet = socket.get_packet()
	if socket.was_string_packet():
		var data = JSON.parse_string(packet.get_string_from_utf8())
		return data
	return bytes_to_var(packet)


func close(code := 1000, reason := "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()


func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


func get_socket() -> WebSocketPeer:
	return socket

func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()
	var state = socket.get_ready_state()
	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			connection_closed.emit()
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		data_received.emit(get_data())

func _process(delta):
	poll()
