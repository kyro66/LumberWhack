extends MultiplayerSpawner

const DRAGGABLE_COMPONENT := preload("res://components/draggable_component.tscn")
const PICKUP_COMPONENT := preload("res://components/pickup_component.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_dropped_item
	pass

func spawn_item(
	item_path: String,
	world_position: Vector3,
	throw_velocity: Vector3
) -> void:
	if not multiplayer.is_server(): return
	
	var items_root := get_node(spawn_path) as Node3D
	
	# get the item locations relative to DroppedItems
	var world_transform := Transform3D(Basis.IDENTITY, world_position)
	var local_transform := items_root.global_transform.affine_inverse() * world_transform
	
	spawn({
		"item_path" = item_path,
		"transform" = local_transform,
		"velocity" = throw_velocity
	})
	
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
	
	var draggable := DRAGGABLE_COMPONENT.instantiate()
	var pickup := PICKUP_COMPONENT.instantiate()
	dropped_item.add_child(draggable)
	dropped_item.add_child(pickup)
	dropped_item.get_node("PickupComponent").item_path = tool.resource_path
	
	dropped_item.set_meta("value", tool.value)
	
	print(dropped_item)
	return dropped_item
	
	
