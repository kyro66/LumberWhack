extends Control




func _on_return_to_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://gameScenes/ui/main_menu.tscn")


func _on_quit_game_button_down() -> void:
	get_tree().quit()
