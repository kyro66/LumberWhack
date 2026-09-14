extends MultiplayerSpawner

@export var tree_scenes: Array[PackedScene]

@export var tree_weights := PackedFloat32Array([
	250.0, # Pine
	80.0,  # Birch
	20.0,  # Maple
	4.0,   # Oak
	1.0    # Ironwood
])

@export_group("Spawn Settings")
@export var tree_density: float = 0.08  #trees per meter

@export var min_z: float = -100.0
@export var max_z: float = 100.0

@export var min_x: float = 50.0
@export var max_x: float = 100.0

@export var min_tree_scale: float = 2.0
@export var max_tree_scale: float = 2.5

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	spawn_function = _custom_tree_spawn

	if not multiplayer.is_server():
		return

	rng.randomize()
	call_deferred("_spawn_initial_trees")

func _spawn_initial_trees() -> void:
	var spawn_area: float = (max_x - min_x) * (max_z - min_z)
	var tree_count := int(tree_density * spawn_area)

	if tree_scenes.size() != tree_weights.size():
		push_error("tree_scenes and tree_weights must have matching sizes.")
		return

	for i in range(tree_count):
		var spawn_data := {
			"position": _get_random_position(),
			"rotation_y": rng.randf_range(0.0, TAU),
			"tree_index": rng.rand_weighted(tree_weights),
			"scale": rng.randf_range(min_tree_scale, max_tree_scale)
		}

		spawn(spawn_data)

func _get_random_position() -> Vector3:
	return Vector3(
		rng.randf_range(min_x, max_x),
		0.0,
		rng.randf_range(min_z, max_z)
	)

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
