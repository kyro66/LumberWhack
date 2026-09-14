extends CharacterBody3D

#region Player Physics Variables
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
#endregion

#region Camera Control Variables
@export var mouse_sens: float = 0.003
@export var min_pitch: float = -80.0 # degrees
@export var max_pitch: float = 80.0 # degrees
#endregion

#region Child References
@export var camera: Camera3D
@onready var hand: Node3D = $Head/Camera3D/Hand
@export var raycast: RayCast3D
#endregion

#region Head bob
@export_group("headbob")
@export var headbob_freq := 2.0
@export var headbob_amplitude := 0.04
var headbob_time := 0.0
#endregion

#region footsteps
@export_group("audio")
@export var footstep_audio: AudioStreamPlayer3D
var footstep_audio_can_play = true
var footstep_landed
#endregion

@export var hold_distance: float = 2.5
var current_draggable: DraggableComponent = null

#region collider
var current_collider: Node3D
#endregion

var player_config: SettingsConfig

func _enter_tree() -> void:
	# When the player is instantiated, set the authority to their ID, which
	# is also the name the PlayerSpawner gave them
	set_multiplayer_authority(int(name))
	player_config = ResourceLoader.load("user://player_config.tres")

func _ready() -> void:
	# Only capture mouse and activate camera if this is the local player's instance
	if is_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false
		
func _process(_delta: float) -> void:
	current_collider = raycast.get_collider()
	
	
	
	
	
	if not current_collider: return
	
	
	
	

func _physics_process(delta: float) -> void:
	# Ignore remote peers
	if !is_multiplayer_authority(): return
	
	player_movement(delta)
	
	if current_draggable != null:
		var target_pos := camera.global_position - camera.global_transform.basis.z * hold_distance
		current_draggable.request_update_drag.rpc(target_pos)

func _unhandled_input(event: InputEvent) -> void:
	# Ignore input events for remote peers
	if !is_multiplayer_authority(): return
	
	# Make sure your not in a UI for everything past this point
	if !Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	
	# Process mouse motion
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_movement(event)
	
	if event.is_action_pressed("interact"):
		if current_collider and current_collider.has_method('interact'):
			current_collider.interact()
			
	if event.is_action_pressed("attack"): 
		if current_draggable == null:
			_try_grab()
	if event.is_action_released("attack"):
		if current_draggable != null:
			_release_grab()

func player_movement(delta: float) -> void: #delta just takes in the delta float from physics process
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Handle Landing Sound
	if not footstep_landed and is_on_floor():
		if footstep_audio:
			play_footstep_sfx.rpc()
	footstep_landed = is_on_floor()

	move_and_slide()
	
	if is_on_floor() and velocity.length() > 0.1:
		headbob_time += delta * velocity.length()
	else:
		headbob_time = 0.0
	footstep_landed = is_on_floor()
	
	var camera_bob_offset = headbob(headbob_time)
	
	if player_config.enable_camera_bobbing:
		camera.transform.origin = camera_bob_offset

func camera_movement(mouse_motion_event: InputEvent) -> void:
	# Rotate player horizontally
	rotate_y(-mouse_motion_event.relative.x * mouse_sens)
	
	# Rotate camera vertically
	camera.rotate_x(-mouse_motion_event.relative.y * mouse_sens)
	
	# Clamp vertical rotation
	var current_pitch: float = camera.rotation_degrees.x
	camera.rotation_degrees.x = clamp(current_pitch, min_pitch, max_pitch)

func headbob(time: float) -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(time * headbob_freq) * headbob_amplitude
	headbob_position.x = cos(time * headbob_freq / 2) * headbob_amplitude
	
	var footstep_threshold = -headbob_amplitude * .002
	if headbob_position.y > footstep_threshold:
		footstep_audio_can_play = true
	elif headbob_position.y <= footstep_threshold and footstep_audio_can_play:
		if footstep_audio and is_on_floor():
			play_footstep_sfx.rpc()
		footstep_audio_can_play = false # FIX: Lock audio until bob goes back up
	
	return headbob_position
	
@rpc("any_peer", "call_local", "reliable")
func play_footstep_sfx():
	if footstep_audio:
		footstep_audio.volume_linear = player_config.master_volume / 1000
		footstep_audio.play()
		
func _try_grab() -> void:
	if not raycast.is_colliding(): return
	
	var collider := raycast.get_collider()
	if collider == null: return
	
	# Locate the component on the hit body
	var component := collider.get_node_or_null("DraggableComponent") as DraggableComponent
	if component != null:
		print("start drag")
		current_draggable = component
		var hit_point := raycast.get_collision_point()
		
		# Request drag start on server
		current_draggable.request_begin_drag.rpc(hit_point)
	
func _release_grab() -> void:
	if current_draggable != null:
		current_draggable.request_end_drag.rpc()
		current_draggable = null
