extends Node3D


func _on_client_button_down() -> void:
	NetworkHandler.start_client()


func _on_server_button_down() -> void:
	NetworkHandler.start_server()
