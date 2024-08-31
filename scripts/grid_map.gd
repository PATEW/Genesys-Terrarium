extends GridMap


@export var width = 128
@export var length = 128
@export var amplitude = 15
@export var water_moist_level = 0.3

@export var offside_wall_height = 3.0

@export var noise: FastNoiseLite
@export var moisture_noise: FastNoiseLite


var tiles_available = {}
var tiles_generated = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	if noise == null:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.05

	if moisture_noise == null:
		moisture_noise = FastNoiseLite.new()
		moisture_noise.seed = randi()
		moisture_noise.frequency = 0.01
	get_all_tiles()
	
	if !tiles_available.is_empty():
		generate_terrain()
		clean_terrain()
		generate_walls()

func generate_walls():
	print(cell_size)
	var wall_scenes = [
		create_wall(cell_size * Vector3(0, offside_wall_height, length / 2 ),Vector3(0.1 * cell_size.x, offside_wall_height, length * cell_size.z)),
		create_wall(cell_size * Vector3(width, offside_wall_height , length / 2), Vector3(0.1, offside_wall_height, length * cell_size.z)),
		create_wall(cell_size * Vector3(width / 2 , offside_wall_height, 0), Vector3(width * cell_size.x, offside_wall_height, 0.1)),
		create_wall(cell_size * Vector3(width / 2 , offside_wall_height , length  ), Vector3(width * cell_size.x, offside_wall_height, 0.1)),
	]
	
	for wall in wall_scenes:
		add_child(wall)

func create_wall(position: Vector3, size:Vector3):
	var wall = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	
	shape.size = size 
	collision_shape.shape = shape
	wall.add_child(collision_shape)
	wall.position = position
	
	# Create mesh for visualization
	#var mesh_instance = MeshInstance3D.new()
	#var mesh = BoxMesh.new()
	#mesh.size = size 
	#mesh_instance.mesh = mesh
	
	# Create material for the mesh
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(1,0,0,1)
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#mesh_instance.material_override = material
	
	#wall.add_child(mesh_instance)
	return wall
	

func generate_terrain():
	for x in range(width):
		for z in range(length):
			var height = noise.get_noise_2d(x,z) * amplitude
			var moisture = moisture_noise.get_noise_2d(x,z)
			
			var tile_type = get_tile_from_noise(height, moisture)
			set_cell_item(Vector3i(x,round(height),z),tiles_available[tile_type])
			tiles_generated[Vector2(x,z)] = {
				"height": height,
				"type": tile_type
			}
			
func clean_terrain():
	for tile in tiles_generated:
		if tiles_generated[tile]["type"] == "ground":
			continue
		var pos = Vector2(tile.x,tile.y)
		var height= tiles_generated[tile]["height"]
		
		var directions = [
		Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1),
		Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)
		]
		
		var water_count = 0
		for dir in directions:
			var neighbor = pos + dir
			if tiles_generated.has(neighbor):
				var neighbor_type = tiles_generated[neighbor]["type"]
				if neighbor_type == "water":
					water_count += 1
				
		if water_count < 3:
			set_cell_item(Vector3i(tile.x,height,tile.y), tiles_available["ground"])
			tiles_generated[tile]["type"] = "ground"

func get_all_tiles():
	var mesh_library = get_mesh_library()
	if mesh_library == null:
		print("No MeshLibrary assigned to this GridMap")
		return []
	
	var tiles = {}
	for item_id in mesh_library.get_item_list():
		var item_name = mesh_library.get_item_name(item_id)
		tiles_available[item_name] = item_id
	
	
func get_tile_from_noise(height, moisture):
	if !tiles_available.has("water") and !tiles_available.has("ground"):
		return;
	if !tiles_available.has("ground"):
		return
	if height < -2 and moisture > water_moist_level:
		return "water"
	else:
		return "ground"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
