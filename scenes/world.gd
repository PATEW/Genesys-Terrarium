extends Node3D

var grass = preload("res://scenes/grass_kennedy.tscn")
var tree = preload("res://scenes/tree.tscn")

var rng = RandomNumberGenerator.new()


@onready var map = $WorldMap
var grass_tiles = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	map.generate_terrain()
	grass_tiles = initialize_grass_tile_dictionary()
	spawn_grass()
	spawn_tree()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func initialize_grass_tile_dictionary():
	var tiles_generated = map.get_tiles_generated()
	var grass_tiles = {}
	
	for tile in tiles_generated:
		# Assuming tile is a Vector2 representing the x and z coordinates
		grass_tiles[tile] = false
	
	return grass_tiles

func spawn_grass():
	var tiles_generated = map.get_tiles_generated()
	var cell_size = map.cell_size

	for tile in tiles_generated:
		if tiles_generated[tile]["type"] == "grass":
			var random_num = rng.randi_range(1, 100)
			
			if random_num == 2:
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
			var random_num = rng.randi_range(1, 1000)
			
			if random_num == 2:
				var tree_instance = tree.instantiate()
				var height = round(tiles_generated[tile]["height"])
				
				# Convert GridMap coordinates to world space
				var world_pos = map.to_global(map.map_to_local(Vector3i(tile.x, height, tile.y)))
				
				# Add a small vertical offset to prevent z-fighting
				world_pos.y += 0.05
				
				
				add_child(tree_instance)
				tree_instance.global_transform.origin = world_pos
				
				var scale_factor = min(cell_size.x, cell_size.z) / 10
				tree_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
				
