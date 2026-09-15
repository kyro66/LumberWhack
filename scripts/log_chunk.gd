extends ChoppableTree

func _ready() -> void:
	is_felled = true
	_build_trunk()
	if chunk_value > 0:
		set_meta("value", chunk_value)
	super._ready()
	freeze = false
	sleeping = false

func _build_trunk() -> void:
	var mesh := CylinderMesh.new()
	mesh.height = trunk_height
	mesh.top_radius = trunk_radius
	mesh.bottom_radius = trunk_radius
	
	if trunk_material != null:
		mesh.material = trunk_material
	else:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.265, 0.122, 0.004)
		mesh.material = mat
	
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "Trunk"
	mesh_inst.mesh = mesh
	mesh_inst.position.y = trunk_height / 2.0
	add_child(mesh_inst)
	
	var shape := CylinderShape3D.new()
	shape.height = trunk_height
	shape.radius = trunk_radius
	
	var collider := CollisionShape3D.new()
	collider.name = "TrunkCollider"
	collider.shape = shape
	collider.position.y = trunk_height / 2.0
	add_child(collider)
