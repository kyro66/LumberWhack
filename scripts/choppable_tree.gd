extends RigidBody3D
class_name ChoppableTree


#region Child References
@onready var canopy: Array[Node] = find_children("Canopy*")
#endregion

#region Tree Stats
@export var health: int = 100
@export var fell_velocity: Vector3 = Vector3(0, 0, 1.5)
@export var is_felled: bool = false
#endregion

func _ready() -> void:
	freeze = true
	
	#throwable = false
	
var attack_cooldowns: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func request_attack(tool_path: String, player_path: NodePath) -> void:
	var tool: ToolData = load(tool_path)
	# Make sure the RPC was called to the server and not a client
	if !multiplayer.is_server(): return
	# Can't do it unless your holding an axe and the tree hasn't been chopped yet
	if is_felled or tool.type != tool.ToolType.AXE: return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var current_time = Time.get_ticks_msec() / 1000.0
	var last_attack = attack_cooldowns.get(sender_id, 0.0)
	
	if current_time - last_attack < tool.cooldown:
		
		return
	
	var player_node = get_node_or_null(player_path)
	if player_node and player_node.has_method("play_hand_swing"):
		player_node.play_hand_swing.rpc()
	
	attack_cooldowns[sender_id] = current_time
	
	
	health -= tool.power
	if health <= 0: fell_tree()
	else:
		AudioManager.create_3d_audio_at_location(
			position, 
			SoundEffect.SOUND_EFFECT_TYPE.TREE_HIT
		)
	
	return 
func fell_tree() -> void:
	# Don't let clients chop trees, or try to chop a chopped tree
	if !multiplayer.is_server() or is_felled: return
	
	AudioManager.create_3d_audio_at_location(
		position, 
		SoundEffect.SOUND_EFFECT_TYPE.TREE_LAST_HIT
	)
	
	is_felled = true
	
	freeze = false
	sleeping = false
	
	angular_velocity = fell_velocity * mass
	
	for i in canopy:
		i.visible = false
