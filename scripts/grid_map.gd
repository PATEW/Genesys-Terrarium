extends GridMap
class_name WorldMap


@export var width = 128
@export var length = 128
@export var amplitude = 15
@export var water_moist_level = 0.3

@export var offside_wall_height = 3.0

@export var noise: FastNoiseLite
@export var moisture_noise: FastNoiseLite
@export var temperature_noise: FastNoiseLite


@export var mud_threshold = 0.4  # New threshold for mud generation


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
		
	if temperature_noise == null:
		temperature_noise = FastNoiseLite.new()
		temperature_noise.seed = randi()
		temperature_noise.frequency = 0.02
	
	get_all_tiles()
	

func get_lowest_block():
	var lowest_tile_height = INF 
	for cell in get_used_cells():
		lowest_tile_height = abs(min(lowest_tile_height, cell.y))
	return lowest_tile_height

func generate_walls():
	var lowest_tile_height = get_lowest_block()
	print(cell_size)
	print(lowest_tile_height)
	var wall_scenes = [
		create_wall(cell_size * Vector3(0, lowest_tile_height, -length / 2 ),Vector3(0.1 * cell_size.x, offside_wall_height, length * cell_size.z)),
		create_wall(cell_size * Vector3(-width, lowest_tile_height , -length / 2), Vector3(0.1, offside_wall_height, length * cell_size.z)),
		create_wall(cell_size * Vector3(-width/2 , lowest_tile_height, 0), Vector3(width * cell_size.x, offside_wall_height, 0.1)),
		create_wall(cell_size * Vector3(-width/2 , lowest_tile_height ,-length ), Vector3(width * cell_size.x, offside_wall_height, 0.1)),
	]
	
	for wall in wall_scenes:
		add_child(wall)

func get_all_tiles():
	var mesh = get_mesh_library()
	if mesh == null:
		print("No MeshLibrary assigned to this GridMap")
		return []
	
	for item_id in mesh.get_item_list():
		var item_name = mesh.get_item_name(item_id)
		tiles_available[item_name] = item_id


func get_tile_from_noise(height, moisture, temperature):
	if tiles_available.is_empty():
		return

	if height < -2 and moisture > water_moist_level:
		return "water"
	if moisture < water_moist_level and height > 1 and temperature > 0:
		return "mud" 
	return "grass"


func generate_terrain():
	generate_inital_tiles()
	clean_terrain()
	generate_walls()


func generate_inital_tiles():
	for x in range(width):
		for z in range(length):
			var x_pos = x - width
			var z_pos = z - length
			var height = noise.get_noise_2d(x_pos,z_pos) * amplitude
			var moisture = moisture_noise.get_noise_2d(x_pos,z_pos)
			var temperature = temperature_noise.get_noise_2d(x_pos, z_pos)
			
			var tile_type = get_tile_from_noise(height, moisture, temperature)
			set_cell_item(Vector3i(x_pos,round(height),z_pos),tiles_available[tile_type])
			tiles_generated[Vector2(x_pos,z_pos)] = {
				"height": height,
				"type": tile_type,
				"moisture": moisture,
				"temperature": temperature_noise
			}

func clean_terrain():
	for tile in tiles_generated:
		if tiles_generated[tile]["type"] == "grass":
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
			set_cell_item(Vector3i(tile.x,height,tile.y), tiles_available["mud"])
			tiles_generated[tile]["type"] = "mud"

func create_wall(pos: Vector3, size:Vector3):
	var wall = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	
	shape.size = size 
	collision_shape.shape = shape
	wall.add_child(collision_shape)
	wall.position = pos
	
	return wall

func get_tiles_generated():
	return tiles_generated
