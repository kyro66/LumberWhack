extends Control


#region Child References
@onready var player_hud: Control = $PlayerHUD

@onready var pause_menu: Control = $PauseMenu
@onready var server_ip: Label = $PauseMenu/ServerIP
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	server_ip.text = "Server Address: " + get_connected_server_ip()

func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"): toggle_pause_menu()

func get_connected_server_ip() -> String:
	var peer = multiplayer.multiplayer_peer
	
	#Verify we are running ENet and connected as client
	if peer is ENetMultiplayerPeer:
		var server_peer: ENetPacketPeer = peer.get_peer(1) # 1 is always the host
		if server_peer:
			return server_peer.get_remote_address()
			
	return "Not connected or invalid peer"

func toggle_pause_menu() -> void:
	if player_hud.visible: # If not paused
		player_hud.visible = false # Hide the hud
		pause_menu.visible = true # Show the pause menu
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Unlock the mouse
	else: # If paused, do the opposite
		player_hud.visible = true
		pause_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
