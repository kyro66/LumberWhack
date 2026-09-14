extends Control

#region Child References
@export var player_hud: Control
@export var hotbar: HFlowContainer
@export var slot: PackedScene
@export var money_label: Label

@export var pause_menu: Control
#endregion

#region Textures
@export var slot_texture: Texture2D
@export var selected_slot_texture: Texture2D
#endregion

#region Working Variables
var active_slot: int = -1
var inv_size: int = 3
var inventory: Array = []
var held_item: ToolData = null
var held_item_path: String
#endregion

@onready var player: CharacterBody3D = $".."

func _ready() -> void:
	create_hotbar()
	player_hud.visible = true
	pause_menu.visible = false
	MoneyManager.money_changed.connect(update_money)
	
	pause_menu.visible = false
	player_hud.visible = true

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
		inventory.append(null)
	update_hotbar()

func set_active_slot(selected_slot: int) -> void:
	if active_slot == selected_slot:
		active_slot = -1
	else:
		active_slot = selected_slot
	
	update_hotbar()

func update_money(amount: int):
	money_label.text = "$%d" % amount

@rpc("any_peer", "call_local", "reliable")
func request_add_item(item_path: String, target_player_id: int = -1):
	if not multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0: sender_id = 1 # Requests from the host may come in as sender = 0
	
	print("Add item requested for %s from %d" % [load(item_path).name, sender_id])
	
	# Ensure non-authority clients aren't making requests for other peers
	if sender_id != get_multiplayer_authority():
		print("Unauthorized item request from peer %d" % sender_id)
		return
		
	var item_resource = load(item_path)
	var target_slot = -1
	
	# Server validates and applies the item additions
	if active_slot != -1 and inventory[active_slot] == null:
		target_slot = active_slot
	else:
		for i in range(inv_size):
			if inventory[i] == null:
				target_slot = i
				break
				
	#if space was found, tell the target peers client to add it
	if target_slot != -1:
		inventory[target_slot] = item_resource
		sync_slot_update.rpc_id(sender_id, target_slot, item_path)
	
	if target_slot == -1:
		return false

	inventory[target_slot] = item_resource
	sync_slot_update.rpc_id(sender_id, target_slot, item_path)
	return true
				
@rpc("any_peer", "call_local", "reliable")
func sync_slot_update(slot_index: int, item_path: String) -> void:
	if item_path == "":
		inventory[slot_index] = null
	else:
		inventory[slot_index] = load(item_path)
		
	update_hotbar()
	
func update_hotbar() -> void:
	var slot_nodes = hotbar.get_children()
	
	for i in range(inv_size):
		if i == active_slot: # Set the slot backgrounds to the default / active texture
			slot_nodes[i].get_node("Background").texture = selected_slot_texture
		else:
			slot_nodes[i].get_node("Background").texture = slot_texture
		
		if inventory[i] != null and inventory[i].icon:
			slot_nodes[i].get_node("Icon").texture = inventory[i].icon
		else:
			slot_nodes[i].get_node("Icon").texture = null
	
	if active_slot < inventory.size():
		if inventory[active_slot]:
			held_item = inventory[active_slot]
			held_item_path = inventory[active_slot].resource_path
		else:
			held_item = null
			held_item_path = ""
		
	player.update_held_item_display(held_item_path)

@rpc("any_peer", "call_local", "reliable")
func request_drop_item(slot_index:int) -> void:
	if not multiplayer.is_server(): return
	
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id == 0: sender_id = 1
	
	# a client can only drop its own items
	if sender_id != get_multiplayer_authority(): return
	
	if slot_index < 0 or slot_index >= inventory.size():
		return
		
	var item: ToolData = inventory[slot_index]
	
	if item == null: return
	
	sync_slot_update.rpc_id(sender_id, slot_index, "")
	
	var spawner: MultiplayerSpawner = get_tree().current_scene.get_node_or_null("DroppedItemSpawner")
	
	if spawner != null:
		var drop_position := player.global_position
		drop_position += -player.global_transform.basis.z * 1.5
		drop_position += Vector3.UP * 1.0
		
		var throw_velocity: Vector3 = -player.global_transform.basis.z * 2.0 * player.throw_force
		
		spawner.spawn_item(
			item.resource_path,
			drop_position,
			throw_velocity
		)
	
func _on_quit_game_button_down() -> void:
	get_tree().quit()

func _on_return_to_game_button_down() -> void:
	toggle_pause_menu()
