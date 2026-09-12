extends Control

#region Button References
@onready var return_button: Button = $Return
@onready var join_button: Button = $JoinHostHFlow/Join
@onready var host_button: Button = $JoinHostHFlow/Host
@onready var ip_text: LineEdit = $IP
@onready var join_host_flow: HFlowContainer = $JoinHostHFlow
#endregion

#region Menu References
const PLAY_MENU_PATH: String = "res://gameScenes/ui/play_menu.tscn"
const LEVEL_1_PATH: String = "res://gameScenes/level_1.tscn"
#endregion

#region Working Variables
# Nothing yet!
#endregion

func _ready() -> void:
	return_button.button_down.connect(_on_return_pressed)
	join_button.button_down.connect(_on_join_pressed)
	host_button.button_down.connect(_on_host_pressed)
	ip_text.text_submitted.connect(_on_ip_submitted)
	
	
func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(PLAY_MENU_PATH)

func _on_join_pressed() -> void:
	_on_ip_submitted(ip_text.text)

func _on_host_pressed() -> void:
	# Start server using the function in scripts/network/network_handler.gd
	NetworkHandler.start_server()
	get_tree().change_scene_to_file(LEVEL_1_PATH)
	
func _on_ip_submitted(new_text: String) -> void:
	# If they leave it blank, use localhost
	if new_text == "": new_text = "localhost"
	
	# Stats the client using network_handler.gd
	NetworkHandler.start_client(new_text)
	get_tree().change_scene_to_file(LEVEL_1_PATH)
