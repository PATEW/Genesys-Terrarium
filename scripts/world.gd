extends Node3D

@export var grass: Resource = preload("res://scenes/textures/grass_kennedy.tscn")
@export var tree: Resource = preload("res://scenes/textures/tree.tscn")
@export var entities: Array[EntityResource] = []
var rng = RandomNumberGenerator.new()

@export_range(0.0, 1.0, 0.01) var grass_spawn_rate:float =  0.02
@export_range(0.0, 1.0, 0.001) var tree_spawn_rate:float =  0.001

@export_range(0.0,1.0,0.01) var model_scale_rate: float = 0.10

@onready var map = $WorldMap
var grass_tiles = {}
var tree_neighbors = {}

const DIRECTIONS = [
	Vector2(1, 0),   # Right
	Vector2(-1, 0),  # Left
	Vector2(0, 1),   # Up (in terms of z-axis)
	Vector2(0, -1),  # Down (in terms of z-axis)
	Vector2(1, 1),   # Top-right
	Vector2(1, -1),  # Bottom-right
	Vector2(-1, 1),  # Top-left
	Vector2(-1, -1)  # Bottom-left

]


func _ready():
	map.generate_terrain()
	grass_tiles = initialize_grass_tile_dictionary()
	tree_neighbors = initialize_tree_neighbors()
	spawn_grass()
	spawn_tree()
	if entities:
		spawn_entities()

func initialize_grass_tile_dictionary():
	var tiles_generated = map.get_tiles_generated()
	
	for tile in tiles_generated:
		grass_tiles[tile] = false
	
	return grass_tiles
	
func initialize_tree_neighbors():
	var tiles_generated = map.get_tiles_generated()
	
	for tile in tiles_generated:
		tree_neighbors[tile] = false
	
	return tree_neighbors
	
func there_is_neighbor_tree(pos):
	var tile_pos = pos
	
	for dir in DIRECTIONS:
		var neighbor_pos = tile_pos + dir
		if tree_neighbors.has(neighbor_pos) and tree_neighbors[neighbor_pos]:
			print("There is neighbor tree")
			return true 
	return false


func spawn_grass():
	var tiles_generated = map.get_tiles_generated()
	var cell_size = map.cell_size

	for tile in tiles_generated:
		if tiles_generated[tile]["type"] == "grass":
			var random_num = rng.randf()
			
			if random_num <= grass_spawn_rate:
				var grass_instance = grass.instantiate()
				var height = round(tiles_generated[tile]["height"])
				
				# Convert GridMap coordinates to world space
				var world_pos = map.to_global(map.map_to_local(Vector3i(tile.x, height, tile.y)))
				
				# Add a small vertical offset to prevent z-fighting
				world_pos.y += 0.05
				
				
				add_child(grass_instance)
				grass_instance.global_transform.origin = world_pos
				
				var scale_factor = min(cell_size.x, cell_size.z) / 10
				grass_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
				grass_tiles[tile] = true
				

func spawn_tree():
	var tiles_generated = map.get_tiles_generated()
	var cell_size = map.cell_size

	for tile in tiles_generated:
		if tiles_generated[tile]["type"] == "grass" and !grass_tiles[tile]:
			var random_num = rng.randf()
			
			if random_num <= tree_spawn_rate and !there_is_neighbor_tree(tile):
				var tree_instance = tree.instantiate()
				var height = round(tiles_generated[tile]["height"])
				
				# Convert GridMap coordinates to world space
				var world_pos = map.to_global(map.map_to_local(Vector3i(tile.x, height, tile.y)))
				
				# Add a small vertical offset to prevent z-fighting
				world_pos.y += 0.05
				
				
				add_child(tree_instance)
				tree_instance.global_transform.origin = world_pos
				
				var scale_factor = min(cell_size.x, cell_size.z) * model_scale_rate
				tree_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
				tree_neighbors[tile] = true
				
func spawn_entities():
	for entity in entities:
		for i in range(entity.count):
			spawn_single_entity(entity)
	
func spawn_single_entity(entity_resource: EntityResource):
	var entity_scene = entity_resource.entity_scene
	var entity_instance = entity_scene.instantiate()
	
	var spawn_pos = get_random_spawn(entity_resource)
	
	add_child(entity_instance)
	entity_instance.global_transform.origin = spawn_pos
	
	entity_instance.scale = Vector3.ONE * entity_resource.scale_factor
		


func get_random_spawn(entity_resource: EntityResource):
	var attempts = 0
	var max_attempts = 100
	var tiles_generated = map.get_tiles_generated()
	
	while attempts < max_attempts:
		var random_tile = tiles_generated.keys()[rng.randi() % tiles_generated.size()]
		var height = tiles_generated[random_tile]["height"]
		
		if tiles_generated[random_tile]["type"] == "grass" or tiles_generated[random_tile]["type"] == "mud":
			var world_pos = map.to_global(map.map_to_local(Vector3i(random_tile.x, height, random_tile.y)))
			world_pos.y += 2
			return world_pos
		attempts += 1
	
	print("Warning could not find position for entity")
	return Vector3.ZERO
