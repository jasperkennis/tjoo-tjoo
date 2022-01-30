extends 'res://addons/gut/test.gd'

var World = load('res://Scripts/World.gd')
var _world = null

func before_each():
	_world = World.new()
	_world.grid_size = 2
	_world.create_cells()
	
func after_each():
	_world.free()

func test_get_tiles_to_keep():
	assert_eq(_world.get_tiles_to_keep([0,1,2,3], [1]), [1])
	assert_eq(_world.get_tiles_to_keep([0,1,2,3], [2]), [2])
	assert_eq(_world.get_tiles_to_keep([0,1,2,3], [0, 3]), [0, 3])
	assert_eq(_world.get_tiles_to_keep([0,1], [0, 3]), [0])
	

