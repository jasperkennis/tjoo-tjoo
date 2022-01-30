extends 'res://addons/gut/test.gd'

var World = load('res://Scripts/World.gd')
var _world = null

func before_each():
	_world = World.new()
	_world.grid_size = 2
	_world.create_cells()
	
func after_each():
	_world.free()

func test_propagate_does_not_change_anything_if_all_values_are_full():
	var result = _world.propagate(Vector2(0,0))

	assert_eq(result, _world.rows)

func test_propagate_changes_neighbour_value():
	_world.rows[0][0] = [1]
	var result = _world.propagate(Vector2(0,0))
	
	assert_eq(len(result[1][0]), 2)
	
func test_perform_wave_function_colapse():
	var result = _world.perform_wave_function_colapse()
	
	assert_eq(len(result[0][0]), 1)
	assert_eq(len(result[1][0]), 1)
	assert_eq(len(result[0][1]), 1)
	assert_eq(len(result[1][1]), 1)
	
func test__is_fully_collapsed():
	_world.rows = [
		[[1], [1]],
		[[1], [1]]
	]
	
	var result = _world._is_fully_collapsed()
	assert_eq(result, true)

