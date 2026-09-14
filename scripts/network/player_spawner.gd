extends MultiplayerSpawner

@export var network_player: PackedScene
@export var spawn_location: Vector3

func _ready() -> void:
	spawn_location = get_tree().current_scene.get_node_or_null("PlayerSpawnLocation").position
	multiplayer.peer_connected.connect(spawn_player)
	spawn_player(1)
	
func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return # Only the server should be running this function
	
	# Create the new player and name it after its Peer ID
	var player: Node = network_player.instantiate()
	player.name = str(id)
	player.position = spawn_location
	
	# Put it in PlayerSpawner/
	get_node(spawn_path).call_deferred("add_child", player)
