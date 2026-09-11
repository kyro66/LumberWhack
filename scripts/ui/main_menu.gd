extends Control

# Button References
@onready var play_button: Button = $VFlowContainer/Play
@onready var settings_button: Button = $VFlowContainer/Settings
@onready var quit_button: Button = $VFlowContainer/Quit

# Next Menu References
const NETWORK_MENU_PATH: String = "res://gameScenes/ui/network_menu.tscn"
const SETTINGS_MENU_PATH: String = "res://gameScenes/ui/settings_menu.tscn"

func _ready() -> void:
	play_button.button_down.connect(_on_play_pressed)
	settings_button.button_down.connect(_on_settings_pressed)
	quit_button.button_down.connect(_on_quit_pressed)
	
func _on_play_pressed():
	get_tree().change_scene_to_file(NETWORK_MENU_PATH)
	
func _on_settings_pressed():
	get_tree().change_scene_to_file(SETTINGS_MENU_PATH)
	
func _on_quit_pressed():
	get_tree().quit()
