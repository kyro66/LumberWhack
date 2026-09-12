extends Control


#region Child References
@onready var player_hud: Control = $PlayerHUD

@onready var pause_menu: Control = $PauseMenu
@onready var server_ip: Label = $PauseMenu/ServerIP
#endregion


func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"): toggle_pause_menu()

func toggle_pause_menu() -> void:
	if player_hud.visible: # If not paused
		player_hud.visible = false # Hide the hud
		pause_menu.visible = true # Show the pause menu
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Unlock the mouse
	else: # If paused, do the opposite
		player_hud.visible = true
		pause_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
