extends MultiplayerSpawner

const DRAGGABLE_COMPONENT := preload("res://components/draggable_component.tscn")
const PICKUP_COMPONENT := preload("res://components/pickup_component.tscn")

func _ready() -> void:
	spawn_function = _spawn_dropped_item

func spawn_item(
	item_path: String,
	world_position: Vector3,
	throw_velocity: Vector3
) -> void:
	if not multiplayer.is_server(): return
	
	var items_root := get_node(spawn_path) as Node3D
	var world_transform := Transform3D(Basis.IDENTITY, world_position)
	var local_transform := items_root.global_transform.affine_inverse() * world_transform
	
	spawn({
		"item_path" = item_path,
		"transform" = local_transform,
		"velocity" = throw_velocity
	})

func spawn_custom_item(data: Dictionary) -> Node:
	if not multiplayer.is_server(): return null
	var items_root := get_node(spawn_path) as Node3D
	if data.has("transform"):
		var world_transform: Transform3D = data["transform"]
		data["transform"] = items_root.global_transform.affine_inverse() * world_transform
	return spawn(data)
	
func _spawn_dropped_item(data: Dictionary) -> Node:
	var tool := load(data["item_path"]) as ToolData
	
	if tool == null or tool.scene == null:
		return null
		
	var dropped_item := tool.scene.instantiate() as RigidBody3D
	
	dropped_item.transform = data["transform"]
	
	dropped_item.freeze = false
	dropped_item.collision_layer = 1
	dropped_item.collision_mask = 1
	dropped_item.linear_velocity = data["velocity"]
	dropped_item.set_multiplayer_authority(1)
	
	# Configure log chunk properties if applicable
	if dropped_item is ChoppableTree:
		if data.has("trunk_height"):
			dropped_item.trunk_height = data["trunk_height"]
		if data.has("trunk_radius"):
			dropped_item.trunk_radius = data["trunk_radius"]
		if data.has("is_felled"):
			dropped_item.is_felled = data["is_felled"]
		if data.has("chunk_value"):
			dropped_item.chunk_value = data["chunk_value"]
		if data.has("trunk_material_path") and data["trunk_material_path"] != "":
			dropped_item.trunk_material = load(data["trunk_material_path"]) as Material
	
	var draggable := DRAGGABLE_COMPONENT.instantiate()
	var pickup := PICKUP_COMPONENT.instantiate()
	dropped_item.add_child(draggable)
	dropped_item.add_child(pickup)
	dropped_item.get_node("PickupComponent").item_path = tool.resource_path
	
	var value = data.get("chunk_value", tool.value)
	dropped_item.set_meta("value", value)
	
	print(dropped_item)
	return dropped_item
