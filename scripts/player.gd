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
@onready var camera: Camera3D = $Camera3D
@onready var hand: Node3D = $Camera3D/Hand
#endregion

func _enter_tree() -> void:
	# When the player is instantiated, set the authority to their ID, which
	# is also the name the PlayerSpawner gave them
	set_multiplayer_authority(int(name))

func _ready() -> void:
	# Only capture mouse and activate camera if this is the local player's instance
	if is_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false

func _physics_process(delta: float) -> void:
	# Ignore remote peers
	if !is_multiplayer_authority(): return
	
	player_movement(delta)

func _unhandled_input(event: InputEvent) -> void:
	# Ignore input events for remote peers
	if !is_multiplayer_authority(): return
			
	# Process mouse motion
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_movement(event)

func player_movement(delta: float) -> void: #delta just takes in the delta float from physics process
	# Make sure your not in a UI
	if !Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	
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

	move_and_slide()

func camera_movement(mouse_motion_event: InputEvent) -> void:
	# Rotate player horizontally
	rotate_y(-mouse_motion_event.relative.x * mouse_sens)
	
	# Rotate camera vertically
	camera.rotate_x(-mouse_motion_event.relative.y * mouse_sens)
	
	# Clamp vertical rotation
	var current_pitch: float = camera.rotation_degrees.x
	camera.rotation_degrees.x = clamp(current_pitch, min_pitch, max_pitch)
