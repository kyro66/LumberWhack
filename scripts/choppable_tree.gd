class_name ChoppableTree
extends Draggable

#region Child References
@onready var canopy: Array[Node] = find_children("canopy*")
#endregion

#region Tree Stats
@export var health: int = 100
@export var fell_velocity: Vector3 = Vector3(0, 0, 1.5)
@export var is_felled: bool = false
#endregion

func _ready() -> void:
	freeze = true
	drag_enabled = false 
	#throwable = false

@rpc("any_peer", "call_local", "reliable")
func request_attack(tool: ToolData) -> void:
	# Make sure the RPC was called to the server and not a client
	if !multiplayer.is_server(): return
	# Can't do it unless your holding an axe and the tree hasn't been chopped yet
	if is_felled or tool.type == tool.ToolType.AXE: return
	
	health -= tool.power
	if health <= 0: fell_tree()
	
func fell_tree() -> void:
	# Don't let clients chop trees, or try to chop a chopped tree
	if !multiplayer.is_server() or is_felled: return
	
	is_felled = true
	drag_enabled = true
	freeze = false
	sleeping = false
	
	angular_velocity = fell_velocity * mass
	
func remove_canopy() -> void:
	for i in canopy:
		i.queue_free()
