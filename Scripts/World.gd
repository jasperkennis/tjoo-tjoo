extends Node2D

const W = Vector2.LEFT
const N = Vector2.UP
const E = Vector2.RIGHT
const S = Vector2.DOWN

const DIRS = [W, N, E, S]

# 0 Clean ground

# 1 Dirt horizontal patch left end
# 2 Dirt horizontal patch middle
# 3 Dirt horizontal patch right end

# 4 Dirt single patch

# 5 Dirt vertical patch top
# 5 Dirt vertical patch middle
# 5 Dirt vertical patch bottom

const CONSTRAINTS = [
	[[0, 3, 4], [0, 1, 2, 3, 4], [0, 1, 4], [0, 1, 2, 3, 4]], # Clean
	
	[[0, 3, 4], [0, 1, 2, 3, 4], [2, 3], [0, 1, 2, 3, 4]], # DirtHorizontalLeft
	[[1, 2], [0, 1, 2, 3, 4], [2, 3], [0, 1, 2, 3, 4]], # DirtHorizontalMiddle
	[[1, 2], [0, 1, 2, 3, 4], [0, 1, 4], [0, 1, 2, 3], 4], # DirtHorizontalRight
	
	[[0, 3, 4], [0, 1, 2, 3, 4], [0, 1, 4], [0, 1, 2, 3, 4]] # DirtSingleSpot
]

var grid_size = 40
var rows = []
var stack: Array
var solve_speed = 1.0

onready var tileMap = $Floor
onready var tiles = [
	tileMap.tile_set.find_tile_by_name("Clean"),
	tileMap.tile_set.find_tile_by_name("DirtHorizontalLeft"),
	tileMap.tile_set.find_tile_by_name("DirtHorizontalMiddle"),
	tileMap.tile_set.find_tile_by_name("DirtHorizontalRight"),
	tileMap.tile_set.find_tile_by_name("DirtSingleSpot")
]

##
## Called when the node enters the scene tree for the first time.
##
func _ready():
	create_cells()
	perform_wave_function_colapse()
	draw_tiles()

##
##
##
func draw_tiles():
	for x in range(grid_size):
		for y in range(grid_size):
			tileMap.set_cell(
				x,
				y,
				tiles[rows[x][y][0]]
			)

##
## Creates the cells that contain the superpositions.
##
func create_cells() -> void:
	var availableTiles = range(len(tiles))
	
	for x in range(grid_size):
		var row = []

		for y in range(grid_size):
			row.append(availableTiles)
			
		rows.append(row)

##
## Performs the actuall colapsing untill all cells have collapsed.
##
func perform_wave_function_colapse():
	while not _is_fully_collapsed():
		_wave_function_step()
	
	return rows


##
## Check if all cells have come down to a single position
##
func _is_fully_collapsed() -> bool:
	for x in range(grid_size):
		for y in range(grid_size):
			if len(rows[x][y]) > 1:
				return false

	return true

##
## Perform 1 step in the wave function
##
func _wave_function_step():
	var coords = _get_lowest_entropy_coords()
	_collapse_at_lowest_coords(coords)
	propagate(coords)

##
## Check all values in the rows to find the one with the least entropy
##
func _get_lowest_entropy_coords() -> Vector2:
	var lowest_entropy = 0
	var lowest_coords = Vector2()

	for x in range(grid_size):
		for y in range(grid_size):
			var entropy = len(rows[x][y])
			if (entropy <= 1):
				continue

			if not lowest_entropy || entropy < lowest_entropy:
				lowest_entropy = entropy
				lowest_coords = Vector2(x, y)

	return lowest_coords

##
## Collapse to a single position
##
func _collapse_at_lowest_coords(coords: Vector2):
	var cell = rows[coords.x][coords.y]
	
	var new_value = cell[randi() % cell.size()]
	
	rows[coords.x][coords.y] = [new_value]

##
## Tell other superpositions to shrink down
##
func propagate(coords: Vector2) -> Array:
	var cell = rows[coords.x][coords.y]
	
	for dir in DIRS:
		var neighbour_coords = coords + dir
		
		if not _coords_are_inside_the_grid(neighbour_coords):
			continue
		
		var neighbour_cell_tiles = rows[neighbour_coords.x][neighbour_coords.y]

		if (len(neighbour_cell_tiles) == 1):
			continue

		var allowed_neighbours = _get_all_possible_neighbours(dir, cell)
		var tile_count_before_filtering = len(neighbour_cell_tiles)
		var tiles_to_keep_on_neighbour = get_tiles_to_keep(
			neighbour_cell_tiles, 
			allowed_neighbours
		)

		if len(tiles_to_keep_on_neighbour) < tile_count_before_filtering:
			if len(tiles_to_keep_on_neighbour) == 0:
				print("Concluded that an empty array should be set, because none of {neighbour_cell_tiles} are allowed out of {allowed_neighbours}".format({
					"neighbour_cell_tiles": neighbour_cell_tiles,
					"allowed_neighbours": allowed_neighbours
				}))
				
			rows[neighbour_coords.x][neighbour_coords.y] = tiles_to_keep_on_neighbour
			propagate(neighbour_coords)
			
	return rows

func get_tiles_to_keep(neighbour_cell, allowed_neighbours) -> Array:
	var tiles_to_keep = []
	
	for tile in neighbour_cell:
		if tile in allowed_neighbours:
			tiles_to_keep.append(tile)
	
	return tiles_to_keep

##
## Gets all allowed neighbours for the given cell
##
func _get_all_possible_neighbours(dir: Vector2, cell: Array):
	var posibilities = []
	var dir_index = DIRS.find(dir)
	
	for tile in cell:
		posibilities += CONSTRAINTS[tile][dir_index]
	
	return posibilities

##
## See if the given location is inside the grid
##
func _coords_are_inside_the_grid(coords) -> bool:
	return not (coords.x < 0 || coords.x > grid_size - 1 || coords.y < 0 || coords.y > grid_size - 1)
	

