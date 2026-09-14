extends Control

#region Button References
@onready var return_button: Button = $Return
@onready var sp_button: Button = $VFlowContainer/Singleplayer
@onready var mp_button: Button = $"VFlowContainer/Multiplayer"
#endregion

#region Main Menu References
const MAIN_MENU_PATH: String = "res://gameScenes/ui/main_menu.tscn"
const NETWORK_MENU_PATH: String = "res://gameScenes/ui/network_menu.tscn"
const LEVEL_1_PATH: String = "res://gameScenes/level_1.tscn"
#endregion

func _ready() -> void:
	return_button.button_down.connect(_on_return_pressed)
	sp_button.button_down.connect(_on_sp_pressed)
	mp_button.button_down.connect(_on_mp_pressed)
	
func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
	
func _on_sp_pressed() -> void:
	# Start a single player instance
	NetworkHandler.start_server(0, 1)
	get_tree().change_scene_to_file(LEVEL_1_PATH)
		
func _on_mp_pressed() -> void:
	get_tree().change_scene_to_file(NETWORK_MENU_PATH)
