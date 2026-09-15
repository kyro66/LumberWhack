extends RigidBody3D
class_name ChoppableTree


#region Child References
@onready var canopy: Array[Node] = find_children("Canopy*")
@onready var dropped_item_spawner = get_tree().current_scene.get_node("Spawners/DroppedItemSpawner")
#endregion

#region Tree Stats
@export var health: int = 100
@export var log_health: int = 100
@export var fell_velocity: Vector3 = Vector3(0, 0, 1.5)
@export var is_felled: bool = false

@export var trunk_height: float = 2.5
@export var trunk_radius: float = 0.2
@export var chunk_value: int = 0
@export var min_split_height: float = 0.4

@export var log_chunk_path: String = "res://tools/log_chunk/log_chunk.tres"

@export var trunk_material: Material
#endregion

func _ready() -> void:
	# Auto-detect trunk size from existing prefabs if not set
	if trunk_height <= 0 and self.has_node("Trunk"):
		var mesh_inst := self.get_node("Trunk") as MeshInstance3D
		if mesh_inst and mesh_inst.mesh is CylinderMesh:
			trunk_height = mesh_inst.mesh.height
	if trunk_radius <= 0 and self.has_node("TrunkCollider"):
		var collider := self.get_node("TrunkCollider") as CollisionShape3D
		if collider and collider.shape is CylinderShape3D:
			trunk_radius = collider.shape.radius
	
	# Auto-detect trunk material from the Trunk mesh
	if trunk_material == null and self.has_node("Trunk"):
		var mesh_inst := self.get_node("Trunk") as MeshInstance3D
		if mesh_inst and mesh_inst.mesh != null:
			if mesh_inst.mesh is CylinderMesh:
				trunk_material = mesh_inst.mesh.material
			else:
				trunk_material = mesh_inst.get_active_material(0)
	
	if not is_felled:
		freeze = true

@rpc("any_peer", "call_local", "reliable")
func request_attack(tool_path: String, hit_point: Vector3) -> void:
	if !multiplayer.is_server(): return
	
	var tool := load(tool_path) as ToolData
	if tool == null or tool.type != ToolData.ToolType.AXE: return
	
	if is_felled:
		chop_log(tool, hit_point)
	else:
		chop_tree(tool)

func chop_tree(tool: ToolData) -> void:
	if !multiplayer.is_server(): return
	health -= tool.power
	if health <= 0:
		fell_tree()

func fell_tree() -> void:
	if !multiplayer.is_server() or is_felled: return
	
	is_felled = true
	freeze = false
	sleeping = false
	angular_velocity = fell_velocity * mass
	
	for i in canopy:
		i.visible = false

func chop_log(tool: ToolData, hit_point: Vector3) -> void:
	if !multiplayer.is_server(): return
	log_health -= tool.power
	if log_health <= 0:
		split_tree(hit_point)

func split_tree(_hit_point: Vector3) -> void:
	if !multiplayer.is_server(): return
	if dropped_item_spawner == null:
		push_error("DroppedItemSpawner not found!")
		queue_free()
		return
	
	if trunk_height < min_split_height:
		queue_free()
		return
	
	var local_hit = to_local(_hit_point)
	var split_y = clamp(local_hit.y, min_split_height, trunk_height - min_split_height)

	var height_a = split_y
	var height_b = trunk_height - split_y

	var local_center_a = Vector3(0, height_a / 2.0, 0)
	var local_center_b = Vector3(0, split_y + height_b / 2.0, 0)

	var piece_a_pos := to_global(local_center_a)
	var piece_b_pos := to_global(local_center_b)
	
	var outward := global_transform.basis.x.normalized()
	var vel_a := outward * 1.5 + linear_velocity * 0.5
	var vel_b := -outward * 1.5 + linear_velocity * 0.5
	
	var new_value := chunk_value / 2
	
	var mat_path := ""
	if trunk_material != null:
		if trunk_material.resource_path != "":
			mat_path = trunk_material.resource_path
		else:
			push_warning("Trunk material is embedded. Save it as external .tres to copy to chunks.")
	
	var data_a := {
		"item_path": log_chunk_path,
		"transform": Transform3D(global_transform.basis, piece_a_pos),
		"velocity": vel_a,
		"trunk_height": height_a,
		"trunk_radius": trunk_radius,
		"chunk_value": new_value,
		"is_felled": true,
		"trunk_material_path": mat_path
	}
	
	var data_b := {
		"item_path": log_chunk_path,
		"transform": Transform3D(global_transform.basis, piece_b_pos),
		"velocity": vel_b,
		"trunk_height": height_b,
		"trunk_radius": trunk_radius,
		"chunk_value": new_value,
		"is_felled": true,
		"trunk_material_path": mat_path
	}
	
	dropped_item_spawner.spawn_custom_item(data_a)
	dropped_item_spawner.spawn_custom_item(data_b)
	
	queue_free()
