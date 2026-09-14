class_name PickupComponent
extends Node

@export var item_path: String

func interact(player_id: int) -> void:
	var player = get_tree().current_scene.get_node("PlayerSpawner").get_node(str(player_id)) as CharacterBody3D
	var hud = player.get_node("HUD")
	
	if hud.request_add_item(item_path, player_id):
		get_parent().queue_free()
