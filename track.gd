extends StaticBody3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	var faces := PackedVector3Array()
	_collect_mesh_faces(self, faces)

	if faces.is_empty():
		push_error("Track mesh has no triangle geometry for collision.")
		return

	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	collision_shape.shape = shape


func _collect_mesh_faces(node: Node, faces: PackedVector3Array) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			var mesh_transform := global_transform.affine_inverse() * mesh_instance.global_transform
			for vertex in mesh_instance.mesh.get_faces():
				faces.append(mesh_transform * vertex)

	for child in node.get_children():
		_collect_mesh_faces(child, faces)
