extends Control


#region Child References
@export var player_hud: Control
@export var hotbar: HFlowContainer
@export var slot: PackedScene

@export var pause_menu: Control
#endregion

#region Textures
@export var slot_texture: Texture2D
@export var selected_slot_texture: Texture2D
#endregion

#region Working Variables
var active_slot: int = 0
var last_active_slot: int = 0
var inv_size: int = 3
var inventory: Array[ToolData] = []
#endregion

func _ready() -> void:
	create_hotbar()

func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"): toggle_pause_menu()
	
	#region Hotbar Slots
	if Input.is_action_just_pressed("slot 0"): set_active_slot(0)
	if Input.is_action_just_pressed("slot 1"): set_active_slot(1)
	if Input.is_action_just_pressed("slot 2"): set_active_slot(2)
	if Input.is_action_just_pressed("slot 3"): set_active_slot(3)
	if Input.is_action_just_pressed("slot 4"): set_active_slot(4)
	if Input.is_action_just_pressed("slot 5"): set_active_slot(5)
	if Input.is_action_just_pressed("slot 6"): set_active_slot(6)
	if Input.is_action_just_pressed("slot 7"): set_active_slot(7)
	if Input.is_action_just_pressed("slot 8"): set_active_slot(8)
	if Input.is_action_just_pressed("slot 9"): set_active_slot(9)
	#endregion

func toggle_pause_menu() -> void:
	if player_hud.visible: # If not paused
		player_hud.visible = false # Hide the hud
		pause_menu.visible = true # Show the pause menu
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Unlock the mouse
	else: # If paused, do the opposite
		player_hud.visible = true
		pause_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func create_hotbar() -> void:
	for i in range(inv_size):
		var new_slot = slot.instantiate()
		new_slot.name = str(i)
		hotbar.add_child(new_slot)

func set_active_slot(selected_slot: int) -> void:
	last_active_slot = active_slot
	active_slot = selected_slot
	
	var last_active = hotbar.find_child(str(last_active_slot))
	var active = hotbar.find_child(str(active_slot))
	
	if last_active:
		var tex = last_active.find_child("TextureRect")
		if tex: tex.texture = slot_texture
		else:
			print("ERROR -- Last Active Slot Texture not found")
	else:
		print("ERROR -- Last Active Slot not found")
		
	if active:
		var tex = active.find_child("TextureRect")
		if tex: tex.texture = selected_slot_texture
		else: print("ERROR -- Active Slot Texture not found")
	else:
		print("ERROR -- Active Slot not found")
	
