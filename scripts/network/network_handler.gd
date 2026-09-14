extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 46026
const MAX_CLIENTS: int = 4

var peer: ENetMultiplayerPeer

func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server(port := PORT, _max_clients := MAX_CLIENTS) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

func start_client(ip_address := IP_ADDRESS, port := PORT) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer
	
func _on_server_disconnected() -> void:
	disconnect_from_server()

func disconnect_from_server() -> void:
	if multiplayer.multiplayer_peer:
		# Close the active network connection
		multiplayer.multiplayer_peer.close()
		# Reset multiplayer peer to clear connection state
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	# Restore client state
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Return to main menu
	get_tree().change_scene_to_file("res://gameScenes/ui/disconnected_menu.tscn")
