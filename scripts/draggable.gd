class_name DraggableComponent
extends Node

@export var pull_strength: float = 100.0
@export var damping: float = 10.0
@export var max_force: float = 1000.0
@export var max_drag_distance: float = 3.0

var is_being_dragged: bool = false
var grab_point_local: Vector3 = Vector3.ZERO
var previous_lock_rotation: bool = false
var body: RigidBody3D

func _ready() -> void:
	body = get_parent() as RigidBody3D
	print(get_parent())
	assert(body != null, "DraggableComponent must be a child of a RigidBody3D")
	
	if not body.has_node("MultiplayerSynchronizer"):
		_setup_synchronizer()

@rpc("any_peer", "call_local", "reliable")
func request_begin_drag(grab_position: Vector3) -> void:
	if not multiplayer.is_server(): return
	
	grab_point_local = body.to_local(grab_position)
	previous_lock_rotation = body.lock_rotation
	body.lock_rotation = true
	body.angular_velocity = Vector3.ZERO
	is_being_dragged = true
	body.sleeping = false

@rpc("any_peer", "call_local", "reliable")
func request_update_drag(target_position: Vector3) -> void:
	if not multiplayer.is_server(): return
	
	body.sleeping = false
	var grab_position := body.to_global(grab_point_local)
	var position_error := target_position - grab_position
	var force_position := grab_position - body.global_position
	var point_velocity := body.linear_velocity + body.angular_velocity.cross(force_position)
	var force := position_error * pull_strength - point_velocity * damping
	
	body.apply_force(force.limit_length(max_force), force_position)

@rpc("any_peer", "call_local", "reliable")
func request_end_drag() -> void:
	if not multiplayer.is_server(): return
	
	is_being_dragged = false
	body.lock_rotation = previous_lock_rotation
	
## Add a component to draggable component to sync the draggable object
func _setup_synchronizer() -> void:
	var sync := MultiplayerSynchronizer.new()
	sync.name = "MultiplayerSynchronizer"
	
	# Configure properties to sync across network
	var config := SceneReplicationConfig.new()
	config.add_property(NodePath(".:global_position"))
	config.add_property(NodePath(".:global_rotation"))
	config.add_property(NodePath(".:linear_velocity"))
	config.add_property(NodePath(".:angular_velocity"))
	
	sync.replication_config = config
	
	# Let the parent load before adding a child
	body.add_child.call_deferred(sync)
