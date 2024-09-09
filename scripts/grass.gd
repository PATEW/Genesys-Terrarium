extends CharacterBody3D

class_name Grass

@export var entity_name: String = "grass0"
@export var entity_health: int = 100
@export var entity_hunger: int = 0
@export var entity_thirst: int = 0
@export var entity_reproduction: int = 0

#@onready var entity_info = $"/root/main/entity_info"
signal grass_clicked(name: String, species: String, health: int, hunger: int, thirst: int, reproduction: int)

func _ready():
	#grass_clicked.connect(entity_info.open_and_update_menu)
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


#func _on_clickable_area_input_event(_camera, event, _event_position, _normal, _shape_idx):
#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#			print("Grass clicked")
#			grass_clicked.emit(entity_name, "Grass", entity_health, entity_hunger, entity_thirst, entity_reproduction)
