extends Control

#region Button References
@onready var return_button: Button = $Return
#endregion

#region Main Menu Reference
const MAIN_MENU_PATH: String = "res://gameScenes/ui/main_menu.tscn"
#endregion

func _ready() -> void:
	return_button.button_down.connect(_on_return_pressed)
	
func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
