extends CharacterBody3D

class_name Grass

func _ready():
	combine_meshes()

func combine_meshes():
	var combined_mesh = ArrayMesh.new()
	var materials = []
	
	for child in get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			for surface_idx in mesh.get_surface_count():
				combined_mesh.add_surface_from_arrays(
					mesh.surface_get_primitive_type(surface_idx),
					mesh.surface_get_arrays(surface_idx)
				)
				var surface_material = child.get_surface_override_material(surface_idx)
		
				materials.append(surface_material if surface_material else child.mesh.surface_get_material(surface_idx))
			child.queue_free()  # Remove the original MeshInstance3D
	
	var new_mesh_instance = MeshInstance3D.new()
	new_mesh_instance.mesh = combined_mesh
	add_child(new_mesh_instance)
	for i in range(materials.size()):
		if materials[i]:
			new_mesh_instance.set_surface_override_material(i, materials[i])

func get_aabb() -> AABB:
	var mesh_instance = get_node_or_null("MeshInstance3D")
	return mesh_instance.get_aabb() if mesh_instance else AABB()
