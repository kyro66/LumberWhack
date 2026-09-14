extends MultiplayerSpawner

@export var tree_scenes: Array[PackedScene]
@export var tree_weights:= PackedFloat32Array([
	250.0, #Pine
	80.0, #Birch
	20.0, #Maple
	4.0, #Oak
	1.0 #Ironwood
])

@export_group("Spawn Settings")
@export var spawn_radius: float = 50.0
@export_range(0.0, 1.0, 0.1) var spawn_density: float = 1.5

@export_group("Exclusion Zone")
@export var exclusion_radius: float = 10.0


func _ready() -> void:
	# Set up the custom spawn function
	spawn_function = _custom_tree_spawn
	
	# Only the server handles spawning
	if not multiplayer.is_server():
		return
	
	# Small delay ensures all network systems/peers are initialized on start
	call_deferred("_spawn_initial_trees")


func _spawn_initial_trees() -> void:
	var spawn_count: int = int(spawn_radius * spawn_density * 10)
	var rng := RandomNumberGenerator.new()

	for i in range(spawn_count):
		var random_pos := _get_valid_random_position()
		var tree_index := rng.rand_weighted(tree_weights)
		var tree_scale := randf_range(2.0, 2.5)

		var spawn_data := {
			"position": random_pos,
			"rotation_y": randf_range(0.0, TAU),
			"tree_index": tree_index,
			"scale": tree_scale
		}

		spawn(spawn_data)


func _get_valid_random_position() -> Vector3:
	var pos_2d := Vector2.ZERO
	var is_invalid := true
	
	# Keep generating coordinates until they sit inside the spawn circle AND outside the exclusion circle
	while is_invalid:
		# Uniform point generation inside the outer circle bounding box
		pos_2d = Vector2(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)
		
		var distance_from_center := pos_2d.length()
		
		# Valid if it is WITHIN the spawn radius AND OUTSIDE the exclusion radius
		var inside_spawn := distance_from_center <= spawn_radius
		var outside_exclusion := distance_from_center >= exclusion_radius
		
		is_invalid = not (inside_spawn and outside_exclusion)
		
	return Vector3(pos_2d.x, 0.0, pos_2d.y)

func select_tree() -> PackedScene:
	var rng := RandomNumberGenerator.new()
	var index := rng.rand_weighted(tree_weights)
	var tree := tree_scenes[index]
	
	return tree

func _custom_tree_spawn(data: Variant) -> Node:
	if data is not Dictionary:
		return null

	var tree_index: int = data.get("tree_index", -1)

	if tree_index < 0 or tree_index >= tree_scenes.size():
		return null

	var tree := tree_scenes[tree_index].instantiate()

	tree.position = data.get("position", Vector3.ZERO)
	tree.rotation.y = data.get("rotation_y", 0.0)

	var tree_scale: float = data.get("scale", 1.0)
	tree.scale = Vector3.ONE * tree_scale

	return tree
