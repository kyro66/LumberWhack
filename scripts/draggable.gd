class_name Draggable
extends RigidBody3D

const GRAVITY_SCALE = 2.5

@export var pull_strength: float = 100
@export var damping: float = 10
@export var max_force: float = 1000
@export var max_drag_distance: float = 3
@export var drag_enabled: bool = true
@export var throwable: bool = true
#@export_range(0.0, 100, 0.1) var throw_speed: float = 8
#@export_range(0.0, 1.0, 0.01) var release_velocity_retention: float = 0.5

var is_being_dragged: bool = false
var grab_point_local: Vector3 = Vector3.ZERO
var previous_lock_rotation: bool = false # temp solution

func _init() -> void:
	# Make physics objects fall more "snappy" when dragged and dropped
	gravity_scale = GRAVITY_SCALE
	
@rpc("any_peer", "call_local", "reliable")
func request_begin_drag(grab_position: Vector3) -> void:
	if !multiplayer.is_server(): return
	
	grab_point_local = to_local(grab_position) # Makes the object reflect your rotation
	previous_lock_rotation = lock_rotation
	lock_rotation = true
	angular_velocity = Vector3.ZERO
	is_being_dragged = true
	sleeping = false
	
@rpc("any_peer", "call_local", "reliable")
func request_update_drag(target_position: Vector3) -> void:
	if !multiplayer.is_server(): return
	
	sleeping = false
	var grab_position := to_global(grab_point_local)
	var position_error := target_position - grab_position
	var force_position := grab_position - global_position
	var point_velocity := linear_velocity + angular_velocity.cross(force_position)
	var force  := position_error * pull_strength - point_velocity * damping
	apply_force(force.limit_length(max_force), force_position)
	
@rpc("any_peer", "call_local", "reliable")
func request_end_drag(_stop_movement: bool = true) -> void:
	if !multiplayer.is_server(): return
	
	is_being_dragged = false
	lock_rotation = previous_lock_rotation
	
	#if stop_movement:
	#	linear_velocity *= release_velocity_retention
	#	angular_velocity = Vector3.ZERO
